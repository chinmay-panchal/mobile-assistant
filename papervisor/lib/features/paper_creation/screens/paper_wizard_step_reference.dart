import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../workspace/widgets/workspace_primary_button.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_text_field.dart';
import 'package:pdf/pdf.dart';
import '../../../../core/utils/pdf_preview_helper.dart';
import '../../../../services/pdf_export_service.dart';
import '../../../../services/reference_paper_service.dart';
import '../../../../services/paper_service.dart';
import '../models/paper_wizard_state.dart';
import '../widgets/wizard_bottom_bar.dart';
import '../widgets/wizard_step_header.dart';
import 'paper_wizard_step_difficulty.dart';
import 'pdf_preview_screen.dart';
import 'saved_pdf_viewer_screen.dart';

class PaperWizardStepReference extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;

  const PaperWizardStepReference({
    super.key,
    required this.subject,
    required this.state,
  });

  @override
  State<PaperWizardStepReference> createState() =>
      _PaperWizardStepReferenceState();
}

class _PaperWizardStepReferenceState extends State<PaperWizardStepReference>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ReferencePaperService _refService = ReferencePaperService();
  final PaperService _paperService = PaperService();

  List<Map<String, dynamic>> _refPapers = [];
  List<Map<String, dynamic>> _aiPapers = [];
  bool _loadingPapers = true;

  // Upload state
  bool _uploading = false;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _yearCtrl = TextEditingController();
  final TextEditingController _examTypeCtrl = TextEditingController();
  String? _pickedFileName;
  String? _pickedFilePath;
  Uint8List? _pickedFileBytes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final cachedRef = _refService.getCachedReferencePapersSync(
      widget.subject['id'],
    );
    final cachedAi = _paperService.getCachedPapersSync(widget.subject['id']);
    if (cachedRef != null || cachedAi != null) {
      _refPapers = cachedRef ?? [];
      _aiPapers = (cachedAi ?? [])
          .where((p) => p['status'] != 'FAILED')
          .toList();
      _loadingPapers = false;
    }
    _fetchPapers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _yearCtrl.dispose();
    _examTypeCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPapers() async {
    if (_refPapers.isEmpty && _aiPapers.isEmpty) {
      setState(() {
        _loadingPapers = true;
      });
    }
    try {
      final results = await Future.wait([
        _refService.listReferencePapers(widget.subject['id']),
        _paperService.listPapersBySubject(widget.subject['id']),
      ]);
      if (mounted) {
        setState(() {
          _refPapers = results[0];
          _aiPapers = results[1].where((p) => p['status'] != 'FAILED').toList();
          _loadingPapers = false;
        });
      }
    } catch (_) {
      if (mounted)
        setState(() {
          _loadingPapers = false;
        });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result.isEmpty) return;
      final picked = result.first;
      final bytes = await picked.readAsBytes();

      setState(() {
        _pickedFilePath = picked.path;
        _pickedFileBytes = bytes;
        _pickedFileName = picked.name;
        if (_titleCtrl.text.trim().isEmpty) {
          _titleCtrl.text = picked.name.replaceAll('.pdf', '');
        }
      });
    } catch (_) {}
  }

  Future<void> _uploadPickedFile() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a title for the reference paper.'),
        ),
      );
      return;
    }
    if (_pickedFilePath == null && _pickedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first.')),
      );
      return;
    }

    setState(() => _uploading = true);

    try {
      final uploaded = await _refService.uploadReferencePaper(
        subjectId: widget.subject['id'],
        title: title,
        filePath: _pickedFilePath,
        fileBytes: _pickedFileBytes,
        fileName: _pickedFileName,
        year: int.tryParse(_yearCtrl.text.trim()),
        examType: _examTypeCtrl.text.trim().isEmpty
            ? null
            : _examTypeCtrl.text.trim(),
      );

      if (mounted) {
        setState(() {
          _uploading = false;
          widget.state.referencePaperId = uploaded['id'];
          _titleCtrl.clear();
          _yearCtrl.clear();
          _examTypeCtrl.clear();
          _pickedFileName = null;
          _pickedFilePath = null;
          _pickedFileBytes = null;
        });
        await _fetchPapers();
        if (!mounted) return;
        _tabController.animateTo(0);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reference paper uploaded and selected!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    final hasSelectedRef = widget.state.referencePaperId != null;

    return Scaffold(
      backgroundColor: WorkspaceTheme.canvas,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
                // Top Step Header (No back arrow)
                WizardStepHeader(
                  subjectName: widget.subject['name'] ?? 'Subject',
                  currentStep: 3,
                  title: 'Reference Paper (Optional)',
                  subtitle:
                      'Select an optional blueprint or skip for custom format',
                  onBack: () => Navigator.pop(context),
                ),

                // Segmented Tab Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: WorkspaceTheme.borderSubtle),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: WorkspaceTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: WorkspaceTheme.isDark ? 0.3 : 0.05,
                          ),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: WorkspaceTheme.textPrimary,
                    unselectedLabelColor: WorkspaceTheme.textSecondary,
                    labelStyle: TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Reference Library'),
                      Tab(text: 'Upload New PDF'),
                    ],
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Library
                      _loadingPapers
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AuthTheme.primary,
                              ),
                            )
                          : (_refPapers.isEmpty && _aiPapers.isEmpty)
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 54,
                                      height: 54,
                                      decoration: BoxDecoration(
                                        color: WorkspaceTheme.surfaceMuted,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.description_outlined,
                                        color: WorkspaceTheme.textTertiary,
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No Reference Papers Yet',
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: WorkspaceTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Upload a previous exam paper or continue in custom format mode.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 12,
                                        color: WorkspaceTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_refPapers.isNotEmpty) ...[
                                    Text(
                                      'PAST REFERENCE PAPERS',
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                        color: WorkspaceTheme.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ..._refPapers.map(
                                      (p) => _buildPaperCard(p, isAi: false),
                                    ),
                                  ],

                                  if (_aiPapers.isNotEmpty) ...[
                                    const SizedBox(height: 18),
                                    Text(
                                      'PREVIOUSLY GENERATED PAPERS',
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                        color: WorkspaceTheme.textTertiary,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    ..._aiPapers.map(
                                      (p) => _buildPaperCard(p, isAi: true),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                      // Tab 2: Upload PDF
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // PDF Drop / Pick Area
                            InkWell(
                              onTap: _uploading ? null : _pickFile,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: _pickedFileName != null
                                      ? (WorkspaceTheme.isDark
                                            ? const Color(
                                                0xFF14532D,
                                              ).withValues(alpha: 0.3)
                                            : const Color(0xFFF0FDF4))
                                      : WorkspaceTheme.surfaceWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _pickedFileName != null
                                        ? const Color(0xFF86EFAC)
                                        : WorkspaceTheme.borderSubtle,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _pickedFileName != null
                                            ? const Color(0xFFDCFCE7)
                                            : (WorkspaceTheme.isDark
                                                  ? const Color(0xFF1E293B)
                                                  : const Color(0xFFEEF2FF)),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: Icon(
                                        _pickedFileName != null
                                            ? Icons.picture_as_pdf_rounded
                                            : Icons.cloud_upload_outlined,
                                        color: _pickedFileName != null
                                            ? const Color(0xFF16A34A)
                                            : WorkspaceTheme.accentCobalt,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _pickedFileName ??
                                          'Tap to select reference PDF',
                                      style: TextStyle(
                                        fontFamily: AuthTheme.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _pickedFileName != null
                                            ? const Color(0xFF16A34A)
                                            : WorkspaceTheme.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _pickedFileName != null
                                          ? 'File selected · Tap to replace'
                                          : 'Supports standard PDF documents (max 50MB)',
                                      style: TextStyle(
                                        fontFamily: AuthTheme.fontFamily,
                                        fontSize: 12,
                                        color: WorkspaceTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Form Inputs
                            AuthTextField(
                              label: 'Paper Title *',
                              hintText: 'e.g. CBSE Class 10 Board Exam 2024',
                              controller: _titleCtrl,
                              prefixIcon: Icons.title_rounded,
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: AuthTextField(
                                    label: 'Year',
                                    hintText: 'e.g. 2024',
                                    controller: _yearCtrl,
                                    prefixIcon: Icons.calendar_today_outlined,
                                    keyboardType: TextInputType.number,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: AuthTextField(
                                    label: 'Exam Type',
                                    hintText: 'e.g. Midterm / Annual',
                                    controller: _examTypeCtrl,
                                    prefixIcon: Icons.bookmark_border_rounded,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Upload Button
                            WorkspacePrimaryButton(
                              text: 'Upload & Select Paper',
                              icon: const Icon(
                                Icons.upload_file_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              isLoading: _uploading,
                              onPressed:
                                  (_pickedFileName != null ||
                                          _pickedFilePath != null) &&
                                      !_uploading
                                  ? _uploadPickedFile
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Action Bar
                WizardBottomBar(
                  text: hasSelectedRef ? 'Continue' : 'Continue (Custom Mode)',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaperWizardStepDifficulty(
                          subject: widget.subject,
                          state: widget.state,
                        ),
                      ),
                    );
                  },
                  helperWidget: hasSelectedRef
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AuthTheme.success,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Reference paper selected as exam blueprint',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    color: Color(0xFF065F46),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(
                                  () => widget.state.referencePaperId = null,
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    color: AuthTheme.error,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _previewPaper(
    Map<String, dynamic> paper, {
    bool isAi = false,
  }) async {
    final title = (paper['title'] ?? 'Paper Preview').toString();
    final pdfUrl = (paper['pdf_url'] ?? paper['file_url'])?.toString();

    // 1. If static PDF file is available, preview via remote PDF helper
    if (pdfUrl != null && pdfUrl.trim().isNotEmpty) {
      await PdfPreviewHelper.openRemotePdf(
        context,
        urlPath: pdfUrl,
        title: title,
      );
      return;
    }

    // 2. Pure JSON paper (AI generated): render PDF on-the-fly and display
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          color: AuthTheme.textPrimary,
          strokeWidth: 2.5,
        ),
      ),
    );

    try {
      Map<String, dynamic> fullPaper = Map<String, dynamic>.from(paper);
      // If questions are missing from the list item, fetch full paper object
      if (fullPaper['questions'] == null && fullPaper['id'] != null) {
        try {
          final fetched = await _paperService.getPaper(
            fullPaper['id'].toString(),
          );
          fullPaper = fetched;
        } catch (_) {}
      }

      final bytes = await PdfExportService.generatePaperPdf(
        PdfPageFormat.a4,
        widget.subject,
        fullPaper,
      );

      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SavedPdfViewerScreen(pdfBytes: bytes, title: title),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading dialog

      // Fallback: If on-the-fly byte generation throws, open read-only PdfPreviewScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            subject: widget.subject,
            paper: paper,
            isReadOnly: true,
          ),
        ),
      );
    }
  }

  Widget _buildPaperCard(Map<String, dynamic> paper, {bool isAi = false}) {
    final id = paper['id'] as String;
    final isSelected = widget.state.referencePaperId == id;
    final title = paper['title'] ?? 'Untitled Paper';
    final year = paper['year'];
    final examType = paper['exam_type'];
    final totalMarks = paper['total_marks'];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? WorkspaceTheme.accentCobalt
              : WorkspaceTheme.borderSubtle,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? WorkspaceTheme.accentCobalt.withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              if (isSelected) {
                widget.state.referencePaperId = null;
              } else {
                widget.state.referencePaperId = id;
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                // Icon badge
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isAi
                        ? const Color(0xFFF1F5F9)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAi
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFFFECACA),
                    ),
                  ),
                  child: Icon(
                    isAi
                        ? Icons.auto_awesome_rounded
                        : Icons.picture_as_pdf_rounded,
                    color: isAi
                        ? AuthTheme.textPrimary
                        : const Color(0xFFDC2626),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Title and Metadata Tags
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? WorkspaceTheme.accentCobalt
                              : WorkspaceTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          if (year != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: WorkspaceTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$year',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: WorkspaceTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                          if (totalMarks != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: WorkspaceTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '$totalMarks Marks',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: WorkspaceTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                          if (examType != null &&
                              examType.toString().isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: WorkspaceTheme.isDark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                examType.toString(),
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: WorkspaceTheme.accentCobalt,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Preview Paper in-app (Available for ALL papers: PDF or JSON)
                IconButton(
                  icon: Icon(
                    Icons.visibility_outlined,
                    size: 20,
                    color: WorkspaceTheme.textPrimary,
                  ),
                  tooltip: 'Preview Paper',
                  onPressed: () => _previewPaper(paper, isAi: isAi),
                ),

                // Radio Selection indicator
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? WorkspaceTheme.accentCobalt
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? WorkspaceTheme.accentCobalt
                          : WorkspaceTheme.borderSubtle,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
