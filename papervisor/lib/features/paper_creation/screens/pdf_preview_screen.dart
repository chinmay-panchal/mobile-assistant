import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../../services/pdf_export_service.dart';
import '../../../../services/paper_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/custom_element.dart';
import 'paper_editor_screen.dart';
import 'visual_designer_screen.dart';

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

  Uint8List? _logoBytes;
  bool _isSaving = false;
  bool _isSaved = false;   // true after a successful save
  late Map<String, dynamic> _paper;
  List<CustomElement> _customElements = [];

  @override
  void initState() {
    super.initState();
    _paper = Map<String, dynamic>.from(widget.paper);
  }

  Future<void> _pickLogo() async {
    // Step 1: Pick an image file
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;

    // Step 2: Save bytes to a temp file so ImageCropper can read it via path
    final rawBytes = await files.first.readAsBytes();
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/logo_temp.png');
    await tempFile.writeAsBytes(rawBytes);

    // Step 3: Launch cropper
    if (!mounted) return;
    final cropped = await ImageCropper().cropImage(
      sourcePath: tempFile.path,
      compressFormat: ImageCompressFormat.png,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Logo',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          cropFrameColor: AppColors.primary,
          cropGridColor: AppColors.primaryLight,
          lockAspectRatio: false,
          hideBottomControls: false,
          initAspectRatio: CropAspectRatioPreset.original,
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
        IOSUiSettings(
          title: 'Crop Logo',
          cancelButtonTitle: 'Cancel',
          doneButtonTitle: 'Done',
          aspectRatioPresets: [
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
          ],
        ),
      ],
    );

    // Step 4: Read cropped bytes and update state
    if (cropped != null) {
      final croppedBytes = await cropped.readAsBytes();
      setState(() {
        _logoBytes = croppedBytes;
        _isSaved = false; // Logo changed → mark unsaved
      });
    }
  }

  void _removeLogo() {
    setState(() {
      _logoBytes = null;
      _isSaved = false;
    });
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
      // Re-generate the PDF bytes (same as the preview, including logo)
      final pdfBytes = await PdfExportService.generatePaperPdf(
        PdfPageFormat.a4,
        widget.subject,
        _paper,
        logoBytes: _logoBytes,
        className: _paper['class_name'] as String?,
        timeAllowedMinutes: _paper['time_allowed_minutes'] as int?,
        customElements: _customElements,
      );

      final title = (_paper['title'] ?? 'paper').toString().replaceAll(' ', '_');
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

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showEditSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 16, 24, MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Edit Paper',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Customize your exam paper appearance',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),

              // Logo section card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    // Logo preview box
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _logoBytes != null
                              ? AppColors.primary
                              : Colors.grey[300]!,
                          width: _logoBytes != null ? 2 : 1,
                        ),
                      ),
                      child: _logoBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(11),
                              child: Image.memory(
                                _logoBytes!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              color: Colors.grey[400],
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Institution Logo',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _logoBytes != null
                                ? 'Logo added — appears top-right in PDF'
                                : 'Will appear in top-right corner of PDF',
                            style: TextStyle(
                              fontSize: 12,
                              color: _logoBytes != null
                                  ? AppColors.success
                                  : Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  await _pickLogo();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.primaryDark,
                                        AppColors.primaryLight,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _logoBytes != null ? 'Change' : 'Upload',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              if (_logoBytes != null) ...[
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    _removeLogo();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.red[200]!),
                                    ),
                                    child: Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: Colors.red[600],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Edit content card
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  final updatedPaper = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaperEditorScreen(paper: _paper),
                    ),
                  );
                  if (updatedPaper != null && mounted) {
                    setState(() {
                      _paper = updatedPaper;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.edit_document, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Edit Paper Content', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('Modify questions, titles, marks, and time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Visual Designer card
              GestureDetector(
                onTap: () async {
                  Navigator.pop(ctx);
                  final newElements = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VisualDesignerScreen(
                        subject: widget.subject,
                        paper: _paper,
                        initialElements: _customElements,
                        initialLogoBytes: _logoBytes,
                      ),
                    ),
                  );
                  if (newElements != null && mounted) {
                    setState(() {
                      _customElements = List<CustomElement>.from(newElements);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.design_services, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Visual Designer (Drag & Drop)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            SizedBox(height: 2),
                            Text('Add floating text and images', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Info note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 16, color: AppColors.primaryLight),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PDF will regenerate automatically after logo change.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = _paper['title'] ?? 'Generated Paper';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'PDF Preview',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (!widget.isReadOnly) ...[
            // ── Saved badge ──
            if (_isSaved)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.cloud_done, size: 12, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // ── Save button ──
            _isSaving
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.save_alt_outlined, color: Colors.white),
                    tooltip: 'Save PDF to cloud',
                    onPressed: _savePdf,
                  ),
            // ── Edit button ──
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white),
              tooltip: 'Edit Paper',
              onPressed: _showEditSheet,
            ),
          ],
        ],
      ),
      body: PdfPreview(
        // ValueKey forces a full rebuild of PdfPreview when logo changes
        key: ValueKey(_logoBytes.hashCode),
        build: (format) => PdfExportService.generatePaperPdf(
          format,
          widget.subject,
          _paper,
          logoBytes: _logoBytes,
          className: _paper['class_name'] as String?,
          timeAllowedMinutes: _paper['time_allowed_minutes'] as int?,
          customElements: _customElements,
        ),
        pdfFileName: '${title.replaceAll(' ', '_')}.pdf',
        canChangeOrientation: false,
        canChangePageFormat: false,
        canDebug: false,
      ),
    );
  }
}
