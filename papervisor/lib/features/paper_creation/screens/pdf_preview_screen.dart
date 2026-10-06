import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../services/pdf_export_service.dart';
import '../../../../services/paper_service.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../models/custom_element.dart';
import '../widgets/pdf_preview_header.dart';
import '../widgets/preview_walkthrough_overlay.dart';
import 'paper_editor_screen.dart';
import 'visual_designer_screen.dart';

/// Redesigned PDF Preview Screen matching the Papervisor design system.
/// Features a modern top control bar (Save, Edit, Print, Share, Saved badge),
/// a clean neutral document canvas, and an interactive feature tour for first-time users.
class PdfPreviewScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> paper;
  final bool isReadOnly;

  const PdfPreviewScreen({
    super.key,
    required this.subject,
    required this.paper,
    this.isReadOnly = false,
  });

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  final PaperService _paperService = PaperService();

  static const String _walkthroughPrefKey = 'has_seen_preview_walkthrough';
  final GlobalKey _saveKey = GlobalKey();
  final GlobalKey _editKey = GlobalKey();
  final GlobalKey _printKey = GlobalKey();
  final GlobalKey _shareKey = GlobalKey();
  bool _showWalkthrough = false;

  bool _isSaving = false;
  bool _isSaved = false; // true after a successful save
  bool _hasEdited =
      false; // true only after user actually edits content or custom elements
  late Map<String, dynamic> _paper;
  List<CustomElement> _customElements = [];
  int _previewRevision = 0;

  String _computeElementsSignature() {
    final buffer = StringBuffer();
    for (final el in _customElements) {
      buffer.write(
        '${el.id}_${el.pageIndex}_${el.relativeX.toStringAsFixed(4)}_${el.relativeY.toStringAsFixed(4)}_${el.scale.toStringAsFixed(3)}_${el.fontSize}_${el.text}_',
      );
    }
    return buffer.toString();
  }

  @override
  void initState() {
    super.initState();
    _paper = Map<String, dynamic>.from(widget.paper);
    _checkFirstTimeWalkthrough();
  }

  Future<void> _checkFirstTimeWalkthrough() async {
    if (widget.isReadOnly) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool(_walkthroughPrefKey) ?? false;
      if (!hasSeen && mounted) {
        // Small delay to allow the header action buttons to lay out
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && !_isSaved && !_showWalkthrough) {
            setState(() {
              _showWalkthrough = true;
            });
          }
        });
      }
    } catch (e) {
      //       debugPrint('Error checking walkthrough pref: $e');
    }
  }

  Future<void> _dismissWalkthrough() async {
    setState(() {
      _showWalkthrough = false;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_walkthroughPrefKey, true);
    } catch (e) {
      //       debugPrint('Error saving walkthrough pref: $e');
    }
  }

  void _startWalkthrough() {
    setState(() {
      _showWalkthrough = true;
    });
  }

  Widget _buildEditStepFloatingWidget({required int activeIndex}) {
    return Container(
      width: 236,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x330F172A),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Option 1: Edit content
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: activeIndex == 0
                  ? const Color(0xFFEFF6FF)
                  : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              border: activeIndex == 0
                  ? Border.all(color: const Color(0xFF93C5FD), width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: activeIndex == 0
                        ? Colors.white
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: activeIndex == 0
                          ? const Color(0xFFBFDBFE)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: AuthTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit content',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Questions & marks',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 10.5,
                          color: activeIndex == 0
                              ? AuthTheme.primary
                              : AuthTheme.textSecondary,
                          fontWeight: activeIndex == 0
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeIndex == 0)
                  const Text('👈', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
          // Option 2: Visual Designer
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: activeIndex == 1
                  ? const Color(0xFFF0FDFA)
                  : Colors.transparent,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
              border: activeIndex == 1
                  ? Border.all(color: const Color(0xFF5EEAD4), width: 1.5)
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: activeIndex == 1
                        ? Colors.white
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: activeIndex == 1
                          ? const Color(0xFF99F6E4)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: const Icon(
                    Icons.design_services_rounded,
                    size: 18,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Visual Designer',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Images, logos & drag-drop',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 10.5,
                          color: activeIndex == 1
                              ? const Color(0xFF0D9488)
                              : AuthTheme.textSecondary,
                          fontWeight: activeIndex == 1
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (activeIndex == 1)
                  const Text('👈', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualDesignerVisualDemo() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 2),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          // Visual Canvas Representation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFCBD5E1)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A0F172A),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mock Exam Paper Header line
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 70,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                    Container(
                      width: 34,
                      height: 5,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Draggable Elements: Logo chip and Custom Text chip
                Row(
                  children: [
                    // Draggable Image/Logo Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFF5EEAD4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0D9488),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.image_rounded,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'School Logo',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Drag & Drop',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0D9488),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        Icons.add_rounded,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    // Draggable Custom Text Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF5FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: const Color(0xFFD8B4FE),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.title_rounded,
                                size: 11,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Custom Note',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Move & Resize',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Paper content skeleton lines
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 80,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          // Quick Visual Feature Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeaturePill(
                icon: Icons.open_with_rounded,
                label: 'Drag & Drop',
              ),
              const SizedBox(width: 6),
              _buildFeaturePill(
                icon: Icons.photo_size_select_small_rounded,
                label: 'Pinch & Resize',
              ),
              const SizedBox(width: 6),
              _buildFeaturePill(icon: Icons.copy_rounded, label: 'Duplicate'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturePill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9.5, color: const Color(0xFF0D9488)),
          const SizedBox(width: 3.5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: AuthTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<WalkthroughStep> _buildWalkthroughSteps() {
    final List<WalkthroughStep> steps = [];

    if (!_isSaved && !widget.isReadOnly) {
      // Step 1: Save to Cloud
      steps.add(
        WalkthroughStep(
          key: _saveKey,
          title: 'Save to Cloud',
          description:
              'Save your paper permanently to this subject\'s workspace so you can access it anytime from any device.',
          icon: Icons.cloud_upload_outlined,
          accentColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
          badgeText: 'Step ${steps.length + 1} of 5 • Essential',
        ),
      );

      // Step 2: Edit Content (Option 1)
      steps.add(
        WalkthroughStep(
          key: _editKey,
          title: 'Option 1: Edit Content',
          description:
              'Modify question statements, section titles, instructions, and marks breakdown directly in the editor form.',
          floatingWidget: _buildEditStepFloatingWidget(activeIndex: 0),
          icon: Icons.edit_note_rounded,
          accentColor: const Color(0xFF2563EB),
          iconBgColor: const Color(0xFFEFF6FF),
          badgeText: 'Step ${steps.length + 1} of 5 • Text & Marks',
        ),
      );

      // Step 3: Visual Designer (Option 2)
      steps.add(
        WalkthroughStep(
          key: _editKey,
          title: 'Option 2: Visual Designer',
          description:
              'Open a freeform canvas to drag & drop institution logos, teacher signatures, and custom text notes — plus resize, shift, or remove added elements.',
          floatingWidget: _buildEditStepFloatingWidget(activeIndex: 1),
          customContent: _buildVisualDesignerVisualDemo(),
          icon: Icons.design_services_rounded,
          accentColor: const Color(0xFF0D9488),
          iconBgColor: const Color(0xFFF0FDFA),
          badgeText: 'Step ${steps.length + 1} of 5 • Drag & Drop',
        ),
      );
    }

    steps.add(
      WalkthroughStep(
        key: _printKey,
        title: 'Print Exam Paper',
        description:
            'Directly print the formatted paper to your printer or export to your local device as a ready-to-use print document.',
        icon: Icons.print_outlined,
        accentColor: const Color(0xFF4F46E5),
        iconBgColor: const Color(0xFFEEF2FF),
        badgeText: 'Step ${steps.length + 1} • Output',
      ),
    );

    steps.add(
      WalkthroughStep(
        key: _shareKey,
        title: 'Share with Students',
        description:
            'Quickly distribute this paper via WhatsApp, Email, or copy the direct link for your class and colleagues.',
        icon: Icons.share_outlined,
        accentColor: const Color(0xFF16A34A),
        iconBgColor: const Color(0xFFF0FDF4),
        badgeText: 'Step ${steps.length + 1} • Distribution',
      ),
    );

    return steps;
  }

  Future<Uint8List> _generatePdfBytes([
    PdfPageFormat format = PdfPageFormat.a4,
  ]) {
    return PdfExportService.generatePaperPdf(
      format,
      widget.subject,
      _paper,
      className: _paper['class_name'] as String?,
      timeAllowedMinutes: _paper['time_allowed_minutes'] as int?,
      customElements: _customElements,
    );
  }

  Future<void> _onSaveTapped() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: Color(0xFF0284C7),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Save Paper to Cloud?',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  "After saving this paper to the cloud, you won't be able to edit it anymore on the app.",
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AuthTheme.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: AuthPrimaryButton(
                        text: 'Cancel',
                        isSecondary: true,
                        height: 44,
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthPrimaryButton(
                        text: 'OK',
                        height: 44,
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirmed == true) {
      await _savePdf();
    }
  }

  /// Generates the PDF bytes in memory, then uploads via multipart POST.
  Future<void> _savePdf() async {
    final paperId = _paper['id'] as String?;
    if (paperId == null) {
      _showSnack('Cannot save — paper ID is missing.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final pdfBytes = await _generatePdfBytes();
      final title = (_paper['title'] ?? 'paper').toString().replaceAll(
        ' ',
        '_',
      );
      final fileName = '$title.pdf';

      await _paperService.savePaperPdf(
        paperId: paperId,
        pdfBytes: pdfBytes,
        fileName: fileName,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isSaved = true;
          _hasEdited = false;
        });
        _showSnack('PDF saved successfully!');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnack(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    }
  }

  Future<void> _handlePrint() async {
    final title = (_paper['title'] ?? 'paper').toString().replaceAll(' ', '_');
    await Printing.layoutPdf(
      name: '$title.pdf',
      onLayout: (format) => _generatePdfBytes(format),
    );
  }

  Future<void> _handleShare() async {
    final title = (_paper['title'] ?? 'paper').toString().replaceAll(' ', '_');
    final pdfBytes = await _generatePdfBytes();
    await Printing.sharePdf(bytes: pdfBytes, filename: '$title.pdf');
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? AuthTheme.error : AuthTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleEditContent() async {
    final updatedPaper = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaperEditorScreen(paper: _paper)),
    );
    if (updatedPaper != null && mounted) {
      setState(() {
        _paper = updatedPaper;
        _previewRevision++;
        _isSaved = false;
        _hasEdited = true;
      });
      if (_paper['id'] != null) {
        await _paperService.updatePaperInCache(_paper['id'].toString(), _paper);
      }
    }
  }

  Future<void> _handleOpenVisualDesigner() async {
    final newElements = await Navigator.push<List<CustomElement>>(
      context,
      MaterialPageRoute(
        builder: (_) => VisualDesignerScreen(
          subject: widget.subject,
          paper: _paper,
          initialElements: _customElements,
        ),
      ),
    );
    if (newElements != null && mounted) {
      setState(() {
        _customElements = newElements.map((e) => e.copyWith()).toList();
        _previewRevision++;
        _isSaved = false;
        _hasEdited = true;
      });
    }
  }

  Future<bool> _confirmDiscard() async {
    // If the paper was already saved, is read-only, or NOTHING was edited: bypass dialog!
    if (_isSaved || widget.isReadOnly || !_hasEdited) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Discard Paper?',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to go back? Your edits will be discarded.',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AuthTheme.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: AuthPrimaryButton(
                        text: 'Keep Editing',
                        isSecondary: true,
                        height: 44,
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthPrimaryButton(
                        text: 'Discard',
                        height: 44,
                        isDestructive: true,
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return discard ?? false;
  }

  Future<void> _handleBack() async {
    final shouldPop = await _confirmDiscard();
    if (shouldPop && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String title = _paper['title'] ?? 'Generated Paper';
    final String subjectName = widget.subject['name'] ?? 'Subject';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          final vx = details.primaryVelocity ?? 0;
          if (vx > 250 || vx < -250) {
            _handleBack();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFFF1F5F9), // Calm neutral canvas
          body: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // Top Modern Header
                    PdfPreviewHeader(
                      title: title,
                      subtitle: subjectName,
                      isReadOnly: widget.isReadOnly,
                      isSaved: _isSaved,
                      isSaving: _isSaving,
                      onBack: _handleBack,
                      onSave: _onSaveTapped,
                      onEditContent: _handleEditContent,
                      onVisualDesigner: _handleOpenVisualDesigner,
                      onPrint: _handlePrint,
                      onShare: _handleShare,
                      onStartTour: _startWalkthrough,
                      saveKey: _saveKey,
                      editKey: _editKey,
                      printKey: _printKey,
                      shareKey: _shareKey,
                    ),

                    // Document Canvas Area
                    Expanded(
                      child: Stack(
                        children: [
                          PdfPreview.builder(
                            // ValueKey forces full rebuild of PdfPreview when elements, positions or revision change
                            key: ValueKey(
                              '${_paper.hashCode}_${_previewRevision}_${_computeElementsSignature()}',
                            ),
                            build: _generatePdfBytes,
                            pdfFileName: '${title.replaceAll(' ', '_')}.pdf',
                            maxPageWidth: 720,
                            canChangeOrientation: false,
                            canChangePageFormat: false,
                            canDebug: false,
                            useActions: false,
                            allowPrinting: false,
                            allowSharing: false,
                            actions: const [], // Hides default bottom bar
                            scrollViewDecoration: const BoxDecoration(
                              color: Color(0xFFF1F5F9),
                            ),
                            pagesBuilder: (context, pages) {
                              return LayoutBuilder(
                                builder: (context, constraints) {
                                  final double pageWidth =
                                      (constraints.maxWidth - 28).clamp(
                                        280.0,
                                        720.0,
                                      );
                                  return InteractiveViewer(
                                    minScale: 1.0,
                                    maxScale: 4.0,
                                    clipBehavior: Clip.none,
                                    child: SingleChildScrollView(
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 20,
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (
                                              int i = 0;
                                              i < pages.length;
                                              i++
                                            ) ...[
                                              Container(
                                                width: pageWidth,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  boxShadow: const [
                                                    BoxShadow(
                                                      color: Color(0x1F000000),
                                                      blurRadius: 10,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                clipBehavior: Clip.antiAlias,
                                                child: Image(
                                                  image: pages[i].image,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                              if (i < pages.length - 1)
                                                const SizedBox(height: 18),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Interactive First-Time Walkthrough Overlay
              if (_showWalkthrough)
                PreviewWalkthroughOverlay(
                  steps: _buildWalkthroughSteps(),
                  onDismiss: _dismissWalkthrough,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
