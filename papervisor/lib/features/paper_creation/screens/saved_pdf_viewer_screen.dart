import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../auth/theme/auth_theme.dart';

/// Full-screen in-app PDF viewer for saved / reference PDFs.
/// Styled with a clean neutral black & white theme matching [PdfPreviewScreen].
/// Renders raw [pdfBytes] with continuous multi-page scrolling, natural A4 width on web,
/// double-tap zoom toggle, and floating zoom controls.
class SavedPdfViewerScreen extends StatefulWidget {
  final Uint8List pdfBytes;
  final String title;

  const SavedPdfViewerScreen({
    super.key,
    required this.pdfBytes,
    required this.title,
  });

  @override
  State<SavedPdfViewerScreen> createState() => _SavedPdfViewerScreenState();
}

class _SavedPdfViewerScreenState extends State<SavedPdfViewerScreen> {
  double _zoomLevel = 1.0;
  late final Uint8List _rawBytes;

  @override
  void initState() {
    super.initState();
    _rawBytes = Uint8List.fromList(widget.pdfBytes);
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    return Uint8List.fromList(_rawBytes);
  }

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
                widget.title,
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
        body: Stack(
          children: [
            PdfPreview.builder(
              build: _buildPdf,
              pdfFileName: '${widget.title.replaceAll(' ', '_')}.pdf',
              maxPageWidth: 720,
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
              pagesBuilder: (context, pages) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final isWebOrDesktop = MediaQuery.of(context).size.width >= 768;
                    final baseWidth = isWebOrDesktop ? 720.0 : (constraints.maxWidth - 28);
                    final targetWidth = baseWidth * _zoomLevel;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (int i = 0; i < pages.length; i++) ...[
                              GestureDetector(
                                onDoubleTap: () {
                                  setState(() {
                                    _zoomLevel = _zoomLevel == 1.0 ? 1.25 : 1.0;
                                  });
                                },
                                child: Container(
                                  width: targetWidth,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
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
                              ),
                              if (i < pages.length - 1) const SizedBox(height: 18),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Floating Zoom Controls
            Positioned(
              bottom: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, size: 18),
                        tooltip: 'Zoom out',
                        visualDensity: VisualDensity.compact,
                        onPressed: _zoomLevel > 0.6
                            ? () => setState(() => _zoomLevel = (_zoomLevel - 0.15).clamp(0.5, 2.0))
                            : null,
                      ),
                      InkWell(
                        onTap: () => setState(() => _zoomLevel = 1.0),
                        borderRadius: BorderRadius.circular(6),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Text(
                            '${(_zoomLevel * 100).round()}%',
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AuthTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, size: 18),
                        tooltip: 'Zoom in',
                        visualDensity: VisualDensity.compact,
                        onPressed: _zoomLevel < 1.8
                            ? () => setState(() => _zoomLevel = (_zoomLevel + 0.15).clamp(0.5, 2.0))
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
