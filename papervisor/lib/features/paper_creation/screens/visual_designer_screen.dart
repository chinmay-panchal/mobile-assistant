import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../services/pdf_export_service.dart';
import '../../auth/theme/auth_theme.dart';
import '../models/custom_element.dart';
import '../widgets/designer_page_sheet.dart';

class VisualDesignerScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> paper;
  final List<CustomElement> initialElements;
  final Uint8List? initialLogoBytes;

  const VisualDesignerScreen({
    super.key,
    required this.subject,
    required this.paper,
    required this.initialElements,
    this.initialLogoBytes,
  });

  @override
  State<VisualDesignerScreen> createState() => _VisualDesignerScreenState();
}

class _VisualDesignerScreenState extends State<VisualDesignerScreen> {
  bool _isLoading = true;
  List<Uint8List> _pdfPages = [];
  final List<CustomElement> _elements = [];

  // Track image sizes per page
  final Map<int, GlobalKey> _imageKeys = {};
  final Map<int, Size> _imageSizes = {};

  // Track base scales for pinch-to-zoom
  final Map<String, double> _baseScales = {};

  // The currently selected/active element for canvas-level pinch scaling
  String? _selectedElementId;

  @override
  void initState() {
    super.initState();
    for (var el in widget.initialElements) {
      _elements.add(el.copyWith());
    }
    _initRaster();
  }

  Future<void> _initRaster() async {
    try {
      final pdfBytes = await PdfExportService.generatePaperPdf(
        PdfPageFormat.a4,
        widget.subject,
        widget.paper,
        className: widget.paper['class_name'] as String?,
        timeAllowedMinutes: widget.paper['time_allowed_minutes'] as int?,
        customElements: const [], // Generate base layer only
      );

      final List<Uint8List> pages = [];
      await for (final page in Printing.raster(pdfBytes, pages: null, dpi: 150)) {
        final pngBytes = await page.toPng();
        pages.add(pngBytes);
      }

      if (mounted) {
        setState(() {
          _pdfPages = pages;
          _isLoading = false;
        });

        // Init keys
        for (int i = 0; i < pages.length; i++) {
          _imageKeys[i] = GlobalKey();
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateImageSizes();
        });
      }
    } catch (e) {
      debugPrint('Error rasterizing PDF: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _updateImageSizes() {
    bool changed = false;
    for (int i = 0; i < _pdfPages.length; i++) {
      final key = _imageKeys[i];
      if (key?.currentContext != null) {
        final box = key!.currentContext!.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          if (_imageSizes[i] != box.size) {
            _imageSizes[i] = box.size;
            changed = true;
          }
        }
      }
    }
    if (changed && mounted) {
      setState(() {});
    }
  }

  void _addTextElement(int pageIndex) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.text_fields_rounded,
                      color: Color(0xFF0284C7),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Add Text',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 14,
                  color: AuthTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter text to place on paper...',
                  hintStyle: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 14,
                    color: AuthTheme.textTertiary,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                    borderSide: const BorderSide(color: AuthTheme.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      foregroundColor: AuthTheme.textSecondary,
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (ctrl.text.trim().isNotEmpty) {
                        setState(() {
                          _elements.add(CustomElement(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            type: CustomElementType.text,
                            text: ctrl.text.trim(),
                            relativeX: 0.5,
                            relativeY: 0.1,
                            pageIndex: pageIndex,
                            scale: 1.0,
                          ));
                        });
                      }
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AuthTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add to Page',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImageElement(int pageIndex) async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;

    final rawBytes = await files.first.readAsBytes();
    if (rawBytes.isEmpty) return;

    Uint8List? bytes;

    if (kIsWeb) {
      bytes = rawBytes;
    } else {
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/designer_img_temp.png');
      await tempFile.writeAsBytes(rawBytes);

      if (!mounted) return;
      final cropped = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        compressFormat: ImageCompressFormat.png,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: AppColors.primary,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (cropped != null) {
        bytes = await cropped.readAsBytes();
      }
    }

    if (bytes != null) {
      setState(() {
        _elements.add(CustomElement(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: CustomElementType.image,
          imageBytes: bytes,
          relativeX: 0.8,
          relativeY: 0.05,
          pageIndex: pageIndex,
          scale: 1.0,
        ));
      });
    }
  }

  void _deleteElement(String id) {
    setState(() {
      _elements.removeWhere((e) => e.id == id);
      _baseScales.remove(id);
      if (_selectedElementId == id) _selectedElementId = null;
    });
  }

  void _duplicateToAllPages(CustomElement source) {
    setState(() {
      for (int i = 0; i < _pdfPages.length; i++) {
        if (i == source.pageIndex) continue; // skip the page it's already on
        _elements.add(CustomElement(
          id: '${DateTime.now().millisecondsSinceEpoch}_p$i',
          type: source.type,
          relativeX: source.relativeX,
          relativeY: source.relativeY,
          pageIndex: i,
          scale: source.scale,
          text: source.text,
          fontSize: source.fontSize,
          imageBytes: source.imageBytes,
        ));
      }
    });
  }

  void _promptAddElement(bool isText) {
    if (_pdfPages.length <= 1) {
      isText ? _addTextElement(0) : _addImageElement(0);
      return;
    }

    DesignerPageSheet.show(
      context: context,
      pageCount: _pdfPages.length,
      isText: isText,
      onPageSelected: (pageIndex) {
        isText ? _addTextElement(pageIndex) : _addImageElement(pageIndex);
      },
    );
  }

  void _showElementOptionsSheet(CustomElement el) {
    AdaptiveModal.show(
      context: context,
      maxWidth: 420,
      builder: (ctx, isDialog) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: isDialog
              ? BorderRadius.circular(24)
              : const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          22,
          isDialog ? 20 : 14,
          22,
          isDialog ? 20 : MediaQuery.of(ctx).viewInsets.bottom + 26,
        ),
        child: SafeArea(
          top: false,
          bottom: !isDialog,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isDialog) ...[
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AuthTheme.inputBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    el.type == CustomElementType.text ? 'Text Options' : 'Image Options',
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                    ),
                  ),
                  if (isDialog)
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, size: 20, color: AuthTheme.textSecondary),
                      splashRadius: 18,
                      tooltip: 'Close',
                    ),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.copy_all_rounded,
                    color: Color(0xFF2563EB),
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Duplicate to all pages',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AuthTheme.textPrimary,
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _duplicateToAllPages(el);
                },
              ),
              const Divider(height: 8, color: Color(0xFFF1F5F9)),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
                title: const Text(
                  'Delete Element',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _deleteElement(el.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showWebBack = kIsWeb && !Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Soft neutral slate canvas
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0)),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  // Optional Back Navigation Button (Shown on Web Desktop/Tablet only, hidden on phones)
                  if (showWebBack) ...[
                    Tooltip(
                      message: 'Back',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              size: 18,
                              color: AuthTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],

                  // Title
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Visual Designer',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AuthTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Drag & position elements on paper',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: AuthTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Back to PDF / Apply changes
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Navigator.pop(context, _elements),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AuthTheme.primary, Color(0xFF6366F1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AuthTheme.primary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Back to PDF',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AuthTheme.primary),
                  ),
                )
              : _pdfPages.isEmpty
                  ? Center(
                      child: Text(
                        'Failed to load PDF preview',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          color: AuthTheme.textSecondary,
                        ),
                      ),
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _updateImageSizes(),
                        );

                        return InteractiveViewer(
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 100),
                            child: Column(
                              children: List.generate(_pdfPages.length, (index) {
                                return _buildPageCanvas(index);
                              }),
                            ),
                          ),
                        );
                      },
                    ),

          // Floating Bottom Toolbar
          if (!_isLoading && _pdfPages.isNotEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1E0F172A),
                        blurRadius: 20,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildToolbarButton(
                        icon: Icons.title_rounded,
                        label: 'Add Text',
                        accentColor: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFF0F9FF),
                        onTap: () => _promptAddElement(true),
                      ),
                      Container(
                        width: 1,
                        height: 24,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: const Color(0xFFE2E8F0),
                      ),
                      _buildToolbarButton(
                        icon: Icons.image_outlined,
                        label: 'Add Image',
                        accentColor: const Color(0xFF7C3AED),
                        bgColor: const Color(0xFFFAF5FF),
                        onTap: () => _promptAddElement(false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required Color accentColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AuthTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPageCanvas(int pageIndex) {
    final imageSize = _imageSizes[pageIndex] ?? Size.zero;
    final pageElements = _elements.where((e) => e.pageIndex == pageIndex).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        // Page index label badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(color: Color(0x080F172A), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Text(
            'Page ${pageIndex + 1} of ${_pdfPages.length}',
            style: const TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AuthTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x140F172A),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onScaleStart: (details) {
                if (_selectedElementId != null) {
                  final el = _elements.firstWhere(
                    (e) => e.id == _selectedElementId,
                    orElse: () => _elements.first,
                  );
                  _baseScales[_selectedElementId!] = el.scale;
                }
              },
              onScaleUpdate: (details) {
                if (_selectedElementId == null) return;
                final el = _elements.firstWhere(
                  (e) => e.id == _selectedElementId,
                  orElse: () => _elements.first,
                );
                setState(() {
                  if (details.pointerCount >= 2 && details.scale != 1.0) {
                    el.scale = ((_baseScales[_selectedElementId!] ?? 1.0) * details.scale)
                        .clamp(0.1, 10.0);
                  }
                });
              },
              child: Stack(
                children: [
                  // Base PDF image
                  Image.memory(
                    _pdfPages[pageIndex],
                    key: _imageKeys[pageIndex],
                    fit: BoxFit.contain,
                  ),

                  // Deselect tap on background
                  if (_selectedElementId != null)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () => setState(() => _selectedElementId = null),
                      ),
                    ),

                  // Custom Overlay Elements
                  if (imageSize.width > 0)
                    ...pageElements.map((el) {
                      final pixelX = el.relativeX * imageSize.width;
                      final pixelY = el.relativeY * imageSize.height;
                      final isSelected = _selectedElementId == el.id;

                      return Positioned(
                        left: pixelX,
                        top: pixelY,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedElementId = el.id),
                          onPanUpdate: (details) {
                            setState(() {
                              _selectedElementId = el.id;
                              el.relativeX += details.delta.dx / imageSize.width;
                              el.relativeY += details.delta.dy / imageSize.height;
                              el.relativeX = el.relativeX.clamp(0.0, 1.0);
                              el.relativeY = el.relativeY.clamp(0.0, 1.0);
                            });
                          },
                          onLongPress: () => _showElementOptionsSheet(el),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isSelected
                                    ? AuthTheme.primary
                                    : AuthTheme.primary.withValues(alpha: 0.35),
                                width: isSelected ? 2.0 : 1.0,
                              ),
                              color: isSelected
                                  ? AuthTheme.primary.withValues(alpha: 0.12)
                                  : Colors.transparent,
                            ),
                            child: _buildElementWidget(el, imageSize),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildElementWidget(CustomElement el, Size imageSize) {
    if (el.type == CustomElementType.text) {
      return Text(
        el.text ?? '',
        style: TextStyle(
          fontSize: (el.fontSize * el.scale) * (imageSize.width / 595.0),
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      );
    } else if (el.type == CustomElementType.image && el.imageBytes != null) {
      return Image.memory(
        el.imageBytes!,
        width: (120 * el.scale) * (imageSize.width / 595.0),
        fit: BoxFit.contain,
      );
    }
    return const SizedBox.shrink();
  }
}
