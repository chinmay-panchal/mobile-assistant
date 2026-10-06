import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../auth/theme/auth_theme.dart';
import '../providers/explore_provider.dart';
import '../repositories/past_downloads_repository.dart';
import '../widgets/explore_clarification_card.dart';
import '../widgets/explore_empty_state.dart';
import '../widgets/explore_error_banner.dart';
import '../widgets/explore_header.dart';
import '../widgets/explore_history_drawer.dart';
import '../widgets/explore_input_composer.dart';
import '../widgets/explore_loading_card.dart';
import '../widgets/explore_result_card.dart';

/// Redesigned Explore PYQs screen adhering strictly to the Papervisor design system.
/// Features clean header (no back button), centered empty state with suggestions,
/// floating input composer, interactive clarification, and right-side history drawer.
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _pulseCtrl;

  ExploreProvider? _exploreProvider;
  DownloadedPdf? _currentResultPdf;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ExploreProvider>();
    if (_exploreProvider != provider) {
      _exploreProvider?.removeListener(_onProviderChange);
      _exploreProvider = provider;
      _exploreProvider?.addListener(_onProviderChange);
    }
  }

  void _onProviderChange() {
    final provider = _exploreProvider;
    if (provider == null) return;
    final pdf = provider.lastDownloadedPdf;
    if (pdf != null) {
      setState(() {
        _currentResultPdf = pdf;
      });
      provider.clearLastDownloaded();
      _openFile(pdf);
    }
  }

  @override
  void dispose() {
    _exploreProvider?.removeListener(_onProviderChange);
    _controller.dispose();
    _focusNode.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _currentResultPdf = null);
    context.read<ExploreProvider>().processPrompt(text);
    _controller.clear();
    _focusNode.unfocus();
  }

  void _handleSuggestion(String suggestion) {
    _controller.text = suggestion;
    _submit();
  }

  void _openHistoryDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  Future<void> _openFile(DownloadedPdf pdf) async {
    if (kIsWeb) {
      if (pdf.sourceUrl.isNotEmpty) {
        final uri = Uri.parse(pdf.sourceUrl);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
          return;
        }
      }
      return;
    }
    final result = await OpenFile.open(pdf.localPath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AuthTheme.error,
          content: Text(
            'Could not open file: ${result.message}',
            style: const TextStyle(fontFamily: AuthTheme.fontFamily),
          ),
        ),
      );
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    final provider = context.watch<ExploreProvider>();
    final isLoading = provider.status == ExploreStatus.loading;
    final downloadCount = provider.downloads.length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: WorkspaceTheme.canvas,
      endDrawer: ExploreHistoryDrawer(
        provider: provider,
        formatDate: _formatDate,
        onOpenFile: _openFile,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                // ── Minimal Top Header (NO Back Button) ─────────────────────
                ExploreHeader(
                  downloadCount: downloadCount,
                  onHistoryTap: _openHistoryDrawer,
                ),

                // ── Error Banner ───────────────────────────────────────────
                if (provider.status == ExploreStatus.error)
                  ExploreErrorBanner(
                    message:
                        provider.errorMessage ??
                        "Couldn't find a downloadable PDF — try rephrasing with subject and year",
                    onDismiss: () =>
                        context.read<ExploreProvider>().resetStatus(),
                  ),

                // ── Ready Download Result Card ─────────────────────────────
                if (_currentResultPdf != null)
                  ExploreResultCard(
                    pdf: _currentResultPdf!,
                    onOpenPdf: () => _openFile(_currentResultPdf!),
                    onDismiss: () => setState(() => _currentResultPdf = null),
                  ),

                // ── Center Content Area ────────────────────────────────────
                Expanded(
                  child: Stack(
                    children: [
                      // Centered Empty / Suggestions State
                      ExploreEmptyState(
                        onSuggestionSelected: _handleSuggestion,
                      ),

                      // Gemini Clarification Dialog / Modal
                      if (provider.status == ExploreStatus.clarifying &&
                          provider.clarificationRequest != null)
                        ExploreClarificationCard(
                          request: provider.clarificationRequest!,
                          onSubmit: (option) => context
                              .read<ExploreProvider>()
                              .submitClarification(option),
                        ),

                      // Loading Pulse Banner Overlay
                      if (isLoading) ExploreLoadingCard(pulseCtrl: _pulseCtrl),
                    ],
                  ),
                ),

                // ── Floating Input Composer ────────────────────────────────
                ExploreInputComposer(
                  controller: _controller,
                  focusNode: _focusNode,
                  isLoading: isLoading,
                  onSubmit: _submit,
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
