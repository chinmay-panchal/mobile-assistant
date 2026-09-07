import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/custom_element.dart';
import '../../../../services/pdf_export_service.dart';

class VisualDesignerScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> paper;
  final List<CustomElement> initialElements;
  final Uint8List? initialLogoBytes;

  const VisualDesignerScreen({
    Key? key,
    required this.subject,
    required this.paper,
    required this.initialElements,
    this.initialLogoBytes,
  }) : super(key: key);

  @override
  State<VisualDesignerScreen> createState() => _VisualDesignerScreenState();
}

class _VisualDesignerScreenState extends State<VisualDesignerScreen> {
  bool _isLoading = true;
  List<Uint8List> _pdfPages = [];
  List<CustomElement> _elements = [];
  
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
        customElements: [], // Generate base layer only
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
    TextEditingController ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Text'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Enter text here...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.isNotEmpty) {
                setState(() {
                  _elements.add(CustomElement(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    type: CustomElementType.text,
                    text: ctrl.text,
                    relativeX: 0.5,
                    relativeY: 0.1,
                    pageIndex: pageIndex,
                    scale: 1.0,
                  ));
                });
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          )
        ],
      ),
    );
  }

  Future<void> _addImageElement(int pageIndex) async {
    final files = await FilePicker.pickFiles(type: FileType.image);
    if (files.isEmpty) return;

    final rawBytes = await files.first.readAsBytes();
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
      final bytes = await cropped.readAsBytes();
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
    if (_pdfPages.length == 1) {
      isText ? _addTextElement(0) : _addImageElement(0);
      return;
    }

    // Ask which page to add it to
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Add to which page?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _pdfPages.length,
                itemBuilder: (ctx, index) {
                  return ListTile(
                    leading: Icon(isText ? Icons.text_fields : Icons.image, color: AppColors.primary),
                    title: Text('Page ${index + 1}'),
                    onTap: () {
                      Navigator.pop(ctx);
                      isText ? _addTextElement(index) : _addImageElement(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('Visual Designer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields, color: AppColors.primary),
            tooltip: 'Add Text',
            onPressed: () => _promptAddElement(true),
          ),
          IconButton(
            icon: const Icon(Icons.image, color: AppColors.primary),
            tooltip: 'Add Image',
            onPressed: () => _promptAddElement(false),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context, _elements);
            },
            child: const Text('Bake to PDF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfPages.isEmpty
              ? const Center(child: Text('Failed to load PDF preview'))
              : LayoutBuilder(
                  builder: (context, constraints) {
                    WidgetsBinding.instance.addPostFrameCallback((_) => _updateImageSizes());
                    
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: SingleChildScrollView(
                        child: Column(
                          children: List.generate(_pdfPages.length, (index) {
                            return _buildPageCanvas(index);
                          }),
                        ),
                      ),
                    );
                  }
                ),
    );
  }

  Widget _buildPageCanvas(int pageIndex) {
    final imageSize = _imageSizes[pageIndex] ?? Size.zero;
    final pageElements = _elements.where((e) => e.pageIndex == pageIndex).toList();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      // Canvas-level GestureDetector captures scale (pinch) from anywhere on the page.
      // It applies the scale to whichever element the user first touched.
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onScaleStart: (details) {
          // Record base scale for the currently selected element
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
            // Only apply scale when it's a true pinch (2 fingers), not just pan
            if (details.pointerCount >= 2 && details.scale != 1.0) {
              el.scale = ((_baseScales[_selectedElementId!] ?? 1.0) * details.scale).clamp(0.1, 10.0);
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
                    // Tap to select this element
                    onTap: () => setState(() => _selectedElementId = el.id),
                    // Single finger drag to move
                    onPanUpdate: (details) {
                      setState(() {
                        _selectedElementId = el.id;
                        el.relativeX += details.delta.dx / imageSize.width;
                        el.relativeY += details.delta.dy / imageSize.height;
                        el.relativeX = el.relativeX.clamp(0.0, 1.0);
                        el.relativeY = el.relativeY.clamp(0.0, 1.0);
                      });
                    },
                    onLongPress: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.copy_all, color: AppColors.primary),
                                title: const Text('Duplicate to all pages'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _duplicateToAllPages(el);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete, color: Colors.red),
                                title: const Text('Delete Element', style: TextStyle(color: Colors.red)),
                                onTap: () {
                                  Navigator.pop(context);
                                  _deleteElement(el.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.3),
                          width: isSelected ? 2.0 : 1.0,
                        ),
                        color: Colors.blueAccent.withOpacity(isSelected ? 0.08 : 0.02),
                      ),
                      child: _buildElementWidget(el, imageSize),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildElementWidget(CustomElement el, Size imageSize) {
    // Apply the scale multiplier to the base sizes
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
