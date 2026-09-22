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
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../models/custom_element.dart';
import '../widgets/pdf_edit_sheet.dart';
import '../widgets/pdf_preview_header.dart';
import 'paper_editor_screen.dart';
import 'visual_designer_screen.dart';

/// Redesigned PDF Preview Screen matching the Papervisor design system.
/// Features a modern top control bar (Save, Edit, Print, Share, Saved badge),
/// a clean neutral document canvas, and a unified bottom sheet for edits.
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
  bool _isSaved = false; // true after a successful save
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
          toolbarColor: AuthTheme.primary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AuthTheme.primary,
          cropFrameColor: AuthTheme.primary,
          cropGridColor: AuthTheme.primaryLight,
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

  Future<Uint8List> _generatePdfBytes([PdfPageFormat format = PdfPageFormat.a4]) {
    return PdfExportService.generatePaperPdf(
      format,
      widget.subject,
      _paper,
      logoBytes: _logoBytes,
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
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
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: '$title.pdf',
    );
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

  void _showEditSheet() {
    PdfEditSheet.show(
      context: context,
      logoBytes: _logoBytes,
      onPickLogo: () async {
        Navigator.pop(context);
        await _pickLogo();
      },
      onRemoveLogo: () {
        Navigator.pop(context);
        _removeLogo();
      },
      onEditContent: () async {
        Navigator.pop(context);
        final updatedPaper = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaperEditorScreen(paper: _paper),
          ),
        );
        if (updatedPaper != null && mounted) {
          setState(() {
            _paper = updatedPaper;
            _isSaved = false;
          });
        }
      },
      onOpenVisualDesigner: () async {
        Navigator.pop(context);
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
            _isSaved = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final String title = _paper['title'] ?? 'Generated Paper';
    final String subjectName = widget.subject['name'] ?? 'Subject';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Calm neutral canvas
      body: SafeArea(
        child: Column(
          children: [
            // Top Modern Header
            PdfPreviewHeader(
              title: title,
              subtitle: subjectName,
              isReadOnly: widget.isReadOnly,
              isSaved: _isSaved,
              isSaving: _isSaving,
              onBack: () => Navigator.pop(context),
              onSave: _onSaveTapped,
              onEdit: _showEditSheet,
              onPrint: _handlePrint,
              onShare: _handleShare,
            ),

            // Document Canvas Area
            Expanded(
              child: PdfPreview(
                // ValueKey forces full rebuild of PdfPreview when logo/elements change
                key: ValueKey('${_logoBytes.hashCode}_${_customElements.length}'),
                build: (format) => _generatePdfBytes(format),
                pdfFileName: '${title.replaceAll(' ', '_')}.pdf',
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
                previewPageMargin: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
