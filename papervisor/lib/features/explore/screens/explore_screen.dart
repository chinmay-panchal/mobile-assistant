import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';
import '../providers/explore_provider.dart';
import '../repositories/past_downloads_repository.dart';

// ── Dark purple palette ───────────────────────────────────────────────────────
class _C {
  static const bg        = Color(0xFF090912);
  static const surface   = Color(0xFF12121F);
  static const card      = Color(0xFF1A1A2E);
  static const inputBg   = Color(0xFF1E1E30); // "light black" for the input
  static const border    = Color(0xFF2E2E50);
  static const purple    = Color(0xFF9B5CFF);
  static const purpleGlow= Color(0x339B5CFF);
  static const text      = Color(0xFFEEEEFF);
  static const textSub   = Color(0xFF8888AA);
  static const error     = Color(0xFFFF5C7A);
  static const errorBg   = Color(0x22FF5C7A);
}

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    // Auto-open the PDF as soon as a download succeeds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExploreProvider>().addListener(_onProviderChange);
    });
  }

  void _onProviderChange() {
    final provider = context.read<ExploreProvider>();
    final pdf = provider.lastDownloadedPdf;
    if (pdf != null) {
      provider.clearLastDownloaded();
      _openFile(pdf);
    }
  }

  @override
  void dispose() {
    context.read<ExploreProvider>().removeListener(_onProviderChange);
    _controller.dispose();
    _focusNode.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    context.read<ExploreProvider>().processPrompt(text);
    _controller.clear();
    _focusNode.unfocus();
  }


  void _openHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HistorySheet(
        provider: context.read<ExploreProvider>(),
        formatDate: _formatDate,
        openFile: _openFile,
      ),
    );
  }

  Future<void> _openFile(DownloadedPdf pdf) async {
    final result = await OpenFile.open(pdf.localPath);
    if (result.type != ResultType.done && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open file: ${result.message}'),
          backgroundColor: _C.error,
        ),
      );
    }
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1)   return '${diff.inMinutes}m ago';
    if (diff.inDays < 1)    return '${diff.inHours}h ago';
    if (diff.inDays == 1)   return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<ExploreProvider>();
    final isLoading = provider.status == ExploreStatus.loading;
    final bottom    = MediaQuery.of(context).padding.bottom;
    final count     = provider.downloads.length;

    return Scaffold(
      backgroundColor: _C.bg,
      appBar: AppBar(
        backgroundColor: _C.bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: _C.text,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const _SearchStarsIcon(size: 18, color: _C.purple),
            const SizedBox(width: 10),
            const Text(
              'Explore PYQs',
              style: TextStyle(
                color: _C.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          // History button with download count badge
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  onPressed: _openHistory,
                  icon: const Icon(Icons.history_rounded),
                  color: count > 0 ? _C.purple : _C.textSub,
                  tooltip: 'History',
                ),
                if (count > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: _C.purple,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _C.border),
        ),
      ),
      body: Column(
        children: [
          // ── Error banner ────────────────────────────────────────────────
          if (provider.status == ExploreStatus.error)
            _ErrorBanner(
              message: provider.errorMessage ??
                  "Couldn't find a downloadable PDF — try rephrasing",
              onDismiss: () =>
                  context.read<ExploreProvider>().resetStatus(),
            ),

          // ── Main body: always the empty/search state ─────────────────
          Expanded(
            child: Stack(
              children: [
                _EmptyState(
                  isLoading: isLoading,
                  pulseCtrl: _pulseCtrl,
                  hasHistory: count > 0,
                  onHistoryTap: _openHistory,
                ),
                if (provider.status == ExploreStatus.clarifying && provider.clarificationRequest != null)
                  _ClarificationView(
                    request: provider.clarificationRequest!,
                    onSubmit: (option) => context.read<ExploreProvider>().submitClarification(option),
                  ),
                if (isLoading) _LoadingOverlay(pulseCtrl: _pulseCtrl),
              ],
            ),
          ),

          // ── Input bar ───────────────────────────────────────────────────
          _InputBar(
            controller: _controller,
            focusNode: _focusNode,
            isLoading: isLoading,
            onSubmit: _submit,
            bottomPadding: bottom,
          ),
        ],
      ),
    );
  }
}

// ── Composite icon: search + stars ────────────────────────────────────────────

class _SearchStarsIcon extends StatelessWidget {
  final double size;
  final Color color;
  const _SearchStarsIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(Icons.search_rounded, size: size, color: color),
        Positioned(
          top: -size * 0.35,
          right: -size * 0.35,
          child: Icon(Icons.auto_awesome, size: size * 0.55, color: color),
        ),
      ],
    );
  }
}

// ── Error banner ──────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;
  const _ErrorBanner({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _C.errorBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.error.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: _C.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: _C.error, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          GestureDetector(
            onTap: onDismiss,
            child:
                const Icon(Icons.close_rounded, color: _C.error, size: 18),
          ),
        ],
      ),
    );
  }
}

// ── Empty / search state ──────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool isLoading;
  final AnimationController pulseCtrl;
  final bool hasHistory;
  final VoidCallback onHistoryTap;

  const _EmptyState({
    required this.isLoading,
    required this.pulseCtrl,
    required this.hasHistory,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: pulseCtrl,
              builder: (_, child) {
                final glow = _C.purpleGlow
                    .withValues(alpha: 0.15 + 0.25 * pulseCtrl.value);
                return Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _C.surface,
                    border: Border.all(color: _C.border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                          color: glow, blurRadius: 32, spreadRadius: 8),
                    ],
                  ),
                  child: child,
                );
              },
              child: const Center(
                child: _SearchStarsIcon(size: 34, color: _C.purple),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Find any PYQ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _C.text,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              isLoading
                  ? 'Searching across the web…'
                  : "Describe the subject and year below\nand we'll find the PDF for you.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: _C.textSub, height: 1.6),
            ),
            if (!isLoading) ...[],
          ],
        ),
      ),
    );
  }
}

// ── Loading overlay ───────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _LoadingOverlay({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      top: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, child) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: _C.card.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _C.purple
                      .withValues(alpha: 0.25 + 0.35 * pulseCtrl.value),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _C.purple
                        .withValues(alpha: 0.08 + 0.12 * pulseCtrl.value),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: child,
            ),
            child: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(_C.purple),
                  ),
                ),
                SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Searching for your PDF…',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _C.text)),
                    SizedBox(height: 2),
                    Text('Trying up to 5 results',
                        style:
                            TextStyle(fontSize: 11.5, color: _C.textSub)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSubmit;
  final double bottomPadding;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSubmit,
    required this.bottomPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        border: Border(top: BorderSide(color: _C.border)),
      ),
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _C.inputBg, // "light black"
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _C.border),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white, // white prompt text
                ),
                decoration: const InputDecoration(
                  hintText: 'Tell me which PYQ \u2014 subject and year',
                  hintStyle: TextStyle(color: _C.textSub, fontSize: 14),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  // Override the global light-theme InputDecorationTheme
                  // which sets filled:true + fillColor:white.
                  filled: true,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: isLoading
                  ? null
                  : const LinearGradient(
                      colors: [Color(0xFF6B3FBF), Color(0xFF9B5CFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: isLoading ? _C.border : null,
              shape: BoxShape.circle,
              boxShadow: isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: _C.purple.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: IconButton(
              onPressed: isLoading ? null : onSubmit,
              icon: const Icon(Icons.send_rounded, size: 19),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── History bottom sheet ──────────────────────────────────────────────────────

class _HistorySheet extends StatefulWidget {
  final ExploreProvider provider;
  final String Function(DateTime) formatDate;
  final Future<void> Function(DownloadedPdf) openFile;

  const _HistorySheet({
    required this.provider,
    required this.formatDate,
    required this.openFile,
  });

  @override
  State<_HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<_HistorySheet> {
  @override
  Widget build(BuildContext context) {
    // Listen to provider changes so the list rebuilds on delete
    final downloads = widget.provider.downloads;
    final bottom    = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: _C.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.80,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: _C.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ── Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.history_rounded,
                    color: _C.purple, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Downloaded PDFs',
                  style: TextStyle(
                    color: _C.text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (downloads.isNotEmpty)
                  TextButton.icon(
                    onPressed: () async {
                      await widget.provider.removeAllDownloads();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(Icons.delete_outline,
                        size: 16, color: _C.error),
                    label: const Text(
                      'Delete All',
                      style: TextStyle(
                        color: _C.error,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 0),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      backgroundColor: _C.errorBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: _C.border, height: 1),

          // ── List
          downloads.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: Column(
                    children: [
                      Icon(Icons.inbox_outlined,
                          color: _C.textSub, size: 40),
                      const SizedBox(height: 12),
                      const Text('No downloads yet',
                          style: TextStyle(
                              color: _C.textSub, fontSize: 14)),
                    ],
                  ),
                )
              : Flexible(
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 16 + bottom),
                    itemCount: downloads.length,
                    separatorBuilder: (_, i) =>
                        const Divider(color: _C.border, height: 1),
                    itemBuilder: (context, index) {
                      final pdf = downloads[index];
                      return _HistoryItem(
                        pdf: pdf,
                        date: widget.formatDate(pdf.downloadedAt),
                        onTap: () => widget.openFile(pdf),
                        onDelete: () {
                          widget.provider.removeDownload(pdf);
                          // Rebuild this sheet
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final DownloadedPdf pdf;
  final String date;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryItem({
    required this.pdf,
    required this.date,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: _C.purpleGlow,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            // PDF badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B3FBF), Color(0xFF9B5CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            // Title + date
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pdf.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _C.text,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded,
                          size: 11, color: _C.textSub),
                      const SizedBox(width: 3),
                      Text(date,
                          style: const TextStyle(
                              fontSize: 11.5, color: _C.textSub)),
                    ],
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded,
                  color: _C.error, size: 20),
              tooltip: 'Delete',
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: _C.card,
                    title: const Text('Delete?',
                        style: TextStyle(color: _C.text)),
                    content: const Text(
                      'This will remove it from history and delete the local file.',
                      style: TextStyle(color: _C.textSub),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel',
                            style: TextStyle(color: _C.textSub)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete',
                            style: TextStyle(color: _C.error)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Clarification UI ──────────────────────────────────────────────────────────

class _ClarificationView extends StatefulWidget {
  final dynamic request; // ClarificationRequest
  final void Function(String) onSubmit;

  const _ClarificationView({required this.request, required this.onSubmit});

  @override
  State<_ClarificationView> createState() => _ClarificationViewState();
}

class _ClarificationViewState extends State<_ClarificationView> {
  final TextEditingController _otherCtrl = TextEditingController();

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.request.question ?? 'Please clarify your search:';
    final options = (widget.request.options as List<dynamic>?)?.cast<String>() ?? [];

    return Container(
      color: _C.bg.withValues(alpha: 0.95), // Cover empty state
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Container(
            decoration: BoxDecoration(
              color: _C.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _C.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          question,
                          style: const TextStyle(
                            color: _C.text,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.request.stepIndex} of ${widget.request.totalSteps}',
                        style: const TextStyle(color: _C.textSub, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Divider(color: _C.border, height: 1),
                
                // Options List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: options.length,
                  separatorBuilder: (_, __) => const Divider(color: _C.border, height: 1),
                  itemBuilder: (context, i) {
                    final opt = options[i];
                    return InkWell(
                      onTap: () => widget.onSubmit(opt),
                      splashColor: _C.purpleGlow,
                      highlightColor: _C.surface,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: _C.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: _C.border),
                              ),
                              child: Center(
                                child: Text(
                                  '${i + 1}',
                                  style: const TextStyle(color: _C.textSub, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                opt,
                                style: const TextStyle(color: _C.text, fontSize: 15),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_rounded, color: _C.textSub, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                
                const Divider(color: _C.border, height: 1),
                
                // Custom input for "Something else"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _C.surface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _C.border),
                        ),
                        child: const Center(
                          child: Icon(Icons.edit_rounded, color: _C.textSub, size: 12),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextField(
                          controller: _otherCtrl,
                          style: const TextStyle(color: _C.text, fontSize: 15),
                          decoration: const InputDecoration(
                            hintText: 'Something else',
                            hintStyle: TextStyle(color: _C.textSub, fontSize: 15),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                          ),
                          onSubmitted: (val) {
                            if (val.trim().isNotEmpty) {
                              widget.onSubmit(val.trim());
                            }
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_otherCtrl.text.trim().isNotEmpty) {
                            widget.onSubmit(_otherCtrl.text.trim());
                          } else {
                            // "Skip" / Default to first option or fallback? 
                            // If they press skip, we just search the original prompt.
                            widget.onSubmit('');
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: _C.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: _C.border),
                          ),
                          minimumSize: const Size(32, 32),
                          padding: EdgeInsets.zero,
                        ),
                        icon: const Icon(Icons.send_rounded, color: _C.text, size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
