import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../auth/theme/auth_theme.dart';

/// Full-screen in-app PDF viewer for saved / reference PDFs.
/// Styled with a clean neutral black & white theme matching [PdfPreviewScreen].
/// Renders raw [pdfBytes] with pure reading controls (no printing, no sharing).
class SavedPdfViewerScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  final String title;

  const SavedPdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(
          primary: AuthTheme.textPrimary,
          secondary: AuthTheme.textSecondary,
        ),
        primaryColor: AuthTheme.textPrimary,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: const IconThemeData(color: AuthTheme.textPrimary),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AuthTheme.textPrimary),
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE2E8F0)),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  color: AuthTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Text(
                'PDF Preview',
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  color: AuthTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: const [],
        ),
        body: PdfPreview(
          build: (_) async => pdfBytes,
          pdfFileName: '${title.replaceAll(' ', '_')}.pdf',
          canChangeOrientation: false,
          canChangePageFormat: false,
          canDebug: false,
          useActions: false,
          allowPrinting: false,
          allowSharing: false,
          actions: const [],
          loadingWidget: const Center(
            child: CircularProgressIndicator(
              color: AuthTheme.textPrimary,
              strokeWidth: 2.5,
            ),
          ),
          scrollViewDecoration: const BoxDecoration(
            color: Color(0xFFF1F5F9),
          ),
          previewPageMargin: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
      ),
    );
  }
}
