import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../services/pdf_export_service.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../models/custom_element.dart';
import '../widgets/designer_page_sheet.dart';
import '../widgets/preview_walkthrough_overlay.dart';

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
  static const String _walkthroughPrefKey = 'has_seen_designer_walkthrough';
  final GlobalKey _addTextKey = GlobalKey();
  final GlobalKey _addImageKey = GlobalKey();
  final GlobalKey _undoRedoKey = GlobalKey();
  final TransformationController _transformationController =
      TransformationController();
  double _currentZoomScale = 1.0;
  bool _showWalkthrough = false;

  bool _isLoading = true;
  List<Uint8List> _pdfPages = [];
  final List<CustomElement> _elements = [];

  // Undo / Redo history stacks
  final List<List<CustomElement>> _undoStack = [];
  final List<List<CustomElement>> _redoStack = [];
  late List<CustomElement> _initialElementsSnapshot;

  Future<void> _checkFirstTimeWalkthrough() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool(_walkthroughPrefKey) ?? false;
      if (!hasSeen && mounted) {
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted &&
              !_isLoading &&
              _pdfPages.isNotEmpty &&
              !_showWalkthrough) {
            setState(() {
              _showWalkthrough = true;
            });
          }
        });
      }
    } catch (e) {
      //       debugPrint('Error checking designer walkthrough pref: $e');
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
      //       debugPrint('Error saving designer walkthrough pref: $e');
    }
  }

  void _startWalkthrough() {
    setState(() {
      _showWalkthrough = true;
    });
  }

  List<WalkthroughStep> _buildWalkthroughSteps() {
    return [
      WalkthroughStep(
        key: _addTextKey,
        title: 'Add Custom Text',
        description:
            'Tap to insert custom section notes, instructions, or exam watermarks, then drag & drop to position and resize them freely anywhere on the paper.',
        icon: Icons.title_rounded,
        accentColor: const Color(0xFF0284C7),
        iconBgColor: const Color(0xFFF0F9FF),
        badgeText: 'Step 1 of 3 • Text Tool',
      ),
      WalkthroughStep(
        key: _addImageKey,
        title: 'Add Images & Logos',
        description:
            'Upload institution logos, teacher signatures, diagrams, or seals from your device, then drag & drop to arrange, scale, or repeat across pages.',
        icon: Icons.image_outlined,
        accentColor: const Color(0xFF7C3AED),
        iconBgColor: const Color(0xFFFAF5FF),
        badgeText: 'Step 2 of 3 • Image Tool',
      ),
      WalkthroughStep(
        key: _undoRedoKey,
        title: 'Undo & Redo Controls',
        description:
            '• Left arrow ↩️ (Undo): Revert accidental moves, resizes, or removals.\n• Right arrow ↪️ (Redo): Restore or re-apply undone changes forward.',
        icon: Icons.history_rounded,
        accentColor: const Color(0xFF475569),
        iconBgColor: const Color(0xFFF1F5F9),
        badgeText: 'Step 3 of 3 • History Controls',
      ),
    ];
  }

  // Track image sizes per page
  final Map<int, GlobalKey> _imageKeys = {};
  final Map<int, Size> _imageSizes = {};

  // Track base scales for pinch-to-zoom
  final Map<String, double> _baseScales = {};

  // The currently selected/active element for canvas-level pinch scaling
  String? _selectedElementId;

  List<CustomElement> _cloneElements(List<CustomElement> list) {
    return list.map((e) => e.copyWith()).toList();
  }

  bool _areElementsEqual(List<CustomElement> a, List<CustomElement> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      final e1 = a[i];
      final e2 = b[i];
      if (e1.id != e2.id ||
          e1.type != e2.type ||
          (e1.relativeX - e2.relativeX).abs() > 0.001 ||
          (e1.relativeY - e2.relativeY).abs() > 0.001 ||
          e1.pageIndex != e2.pageIndex ||
          (e1.scale - e2.scale).abs() > 0.01 ||
          e1.text != e2.text ||
          (e1.fontSize - e2.fontSize).abs() > 0.01 ||
          e1.imageBytes != e2.imageBytes) {
        return false;
      }
    }
    return true;
  }

  bool get _hasUnsavedChanges =>
      !_areElementsEqual(_elements, _initialElementsSnapshot);

  void _saveSnapshot() {
    _undoStack.add(_cloneElements(_elements));
    if (_undoStack.length > 40) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
    if (mounted) setState(() {});
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_cloneElements(_elements));
    final prev = _undoStack.removeLast();
    setState(() {
      _elements.clear();
      _elements.addAll(_cloneElements(prev));
      if (_selectedElementId != null &&
          !_elements.any((e) => e.id == _selectedElementId)) {
        _selectedElementId = null;
      }
    });
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_cloneElements(_elements));
    final next = _redoStack.removeLast();
    setState(() {
      _elements.clear();
      _elements.addAll(_cloneElements(next));
      if (_selectedElementId != null &&
          !_elements.any((e) => e.id == _selectedElementId)) {
        _selectedElementId = null;
      }
    });
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;

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
                  'Discard Changes?',
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
                  'Are you sure you want to go back? All your visual changes will be discarded.',
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

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if ((scale - _currentZoomScale).abs() > 0.05) {
        setState(() {
          _currentZoomScale = scale;
        });
      }
    });
    for (var el in widget.initialElements) {
      _elements.add(el.copyWith());
    }
    _initialElementsSnapshot = _cloneElements(_elements);
    _initRaster();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
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
      await for (final page in Printing.raster(
        pdfBytes,
        pages: null,
        dpi: 150,
      )) {
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
          _checkFirstTimeWalkthrough();
        });
      }
    } catch (e) {
      //       debugPrint('Error rasterizing PDF: $e');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.text_fields_rounded,
                        color: Color(0xFF0284C7),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Add Text',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(12),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ctrl,
                  autofocus: true,
                  style: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    color: AuthTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Enter text to place on paper...',
                    hintStyle: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 13,
                      color: AuthTheme.textTertiary,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AuthTheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        foregroundColor: AuthTheme.textSecondary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (ctrl.text.trim().isNotEmpty) {
                          _saveSnapshot();
                          final newId = DateTime.now().millisecondsSinceEpoch
                              .toString();
                          setState(() {
                            _elements.add(
                              CustomElement(
                                id: newId,
                                type: CustomElementType.text,
                                text: ctrl.text.trim(),
                                relativeX: 0.5,
                                relativeY: 0.1,
                                pageIndex: pageIndex,
                                scale: 1.0,
                              ),
                            );
                            _selectedElementId = newId;
                          });
                        }
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuthTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 32),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Add to Page',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12,
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
      _saveSnapshot();
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      setState(() {
        _elements.add(
          CustomElement(
            id: newId,
            type: CustomElementType.image,
            imageBytes: bytes,
            relativeX: 0.8,
            relativeY: 0.05,
            pageIndex: pageIndex,
            scale: 1.0,
          ),
        );
        _selectedElementId = newId;
      });
    }
  }

  void _zoomElement(CustomElement el, {required bool zoomIn}) {
    _saveSnapshot();
    setState(() {
      _selectedElementId = el.id;
      final double delta = zoomIn ? 0.1 : -0.1;
      final newScale = (el.scale + delta).clamp(0.2, 5.0);
      el.scale = double.parse(newScale.toStringAsFixed(2));
      _baseScales[el.id] = el.scale;
    });
  }

  void _deleteElement(String id) {
    _saveSnapshot();
    setState(() {
      _elements.removeWhere((e) => e.id == id);
      _baseScales.remove(id);
      if (_selectedElementId == id) _selectedElementId = null;
    });
  }

  void _duplicateToAllPages(CustomElement source) {
    _saveSnapshot();
    setState(() {
      for (int i = 0; i < _pdfPages.length; i++) {
        if (i == source.pageIndex) continue; // skip the page it's already on
        _elements.add(
          CustomElement(
            id: '${DateTime.now().millisecondsSinceEpoch}_p$i',
            type: source.type,
            relativeX: source.relativeX,
            relativeY: source.relativeY,
            pageIndex: i,
            scale: source.scale,
            text: source.text,
            fontSize: source.fontSize,
            imageBytes: source.imageBytes,
          ),
        );
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
                    el.type == CustomElementType.text
                        ? 'Text Options'
                        : 'Image Options',
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
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AuthTheme.textSecondary,
                      ),
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

  Future<void> _handleBack() async {
    final shouldPop = await _confirmDiscard();
    if (shouldPop && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          Navigator.pop(context);
          return;
        }
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: const Color(
              0xFFF1F5F9,
            ), // Soft neutral slate canvas
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragEnd: (details) {
                  final vx = details.primaryVelocity ?? 0;
                  if (vx > 200 || vx < -200) {
                    _handleBack();
                  }
                },
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        children: [
                          // Back Navigation Button (Always visible on all screens)
                          Tooltip(
                            message: 'Back',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _handleBack,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AuthTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  'Drag & position elements on paper',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: AuthTheme.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Add Text Button
                          KeyedSubtree(
                            key: _addTextKey,
                            child: Tooltip(
                              message: 'Add Text',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _promptAddElement(true),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF0F9FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFBAE6FD),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.title_rounded,
                                      size: 18,
                                      color: Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Add Image Button
                          KeyedSubtree(
                            key: _addImageKey,
                            child: Tooltip(
                              message: 'Add Image',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _promptAddElement(false),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFAF5FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFFE9D5FF),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 18,
                                      color: Color(0xFF7C3AED),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Subtle Divider between tools and history
                          Container(
                            width: 1,
                            height: 20,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            color: const Color(0xFFE2E8F0),
                          ),
                          const SizedBox(width: 6),

                          // Undo & Redo History Cluster
                          KeyedSubtree(
                            key: _undoRedoKey,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Undo Button
                                Tooltip(
                                  message: _undoStack.isNotEmpty
                                      ? 'Undo'
                                      : 'Nothing to undo',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _undoStack.isNotEmpty
                                          ? _undo
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: _undoStack.isNotEmpty
                                              ? const Color(0xFFF1F5F9)
                                              : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: _undoStack.isNotEmpty
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.undo_rounded,
                                          size: 17,
                                          color: _undoStack.isNotEmpty
                                              ? AuthTheme.textPrimary
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Redo Button
                                Tooltip(
                                  message: _redoStack.isNotEmpty
                                      ? 'Redo'
                                      : 'Nothing to redo',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _redoStack.isNotEmpty
                                          ? _redo
                                          : null,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 34,
                                        height: 34,
                                        decoration: BoxDecoration(
                                          color: _redoStack.isNotEmpty
                                              ? const Color(0xFFF1F5F9)
                                              : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          border: Border.all(
                                            color: _redoStack.isNotEmpty
                                                ? const Color(0xFFCBD5E1)
                                                : const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.redo_rounded,
                                          size: 17,
                                          color: _redoStack.isNotEmpty
                                              ? AuthTheme.textPrimary
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Designer Walkthrough tour button
                          Tooltip(
                            message: 'Designer Walkthrough',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _startWalkthrough,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.help_outline_rounded,
                                    size: 17,
                                    color: AuthTheme.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Done Changes / Apply changes
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(
                                context,
                                _cloneElements(_elements),
                              ),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AuthTheme.primary,
                                      Color(0xFF6366F1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AuthTheme.primary.withValues(
                                        alpha: 0.25,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Done',
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
            ),
            body: Stack(
              children: [
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AuthTheme.primary,
                          ),
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
                            transformationController: _transformationController,
                            minScale: 1.0,
                            maxScale: 4.0,
                            clipBehavior: Clip.none,
                            child: SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.only(bottom: 100),
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: constraints.maxWidth,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: List.generate(_pdfPages.length, (
                                    index,
                                  ) {
                                    return _buildPageCanvas(index);
                                  }),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                // Floating Zoom Reset Pill (shown when zoomed in)
                if (!_isLoading &&
                    _pdfPages.isNotEmpty &&
                    _currentZoomScale > 1.05)
                  Positioned(
                    right: 18,
                    bottom: _selectedElementId != null ? 86 : 24,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _transformationController.value =
                                Matrix4.identity();
                            _currentZoomScale = 1.0;
                          });
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0F172A,
                            ).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x29000000),
                                blurRadius: 10,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.restart_alt_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${(_currentZoomScale * 100).round()}% • Reset',
                                style: const TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
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
                  ),

                // Floating Bottom Toolbar (Only when element is selected)
                if (!_isLoading &&
                    _pdfPages.isNotEmpty &&
                    _selectedElementId != null)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 24,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
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
                        child: Builder(
                          builder: (context) {
                            final selectedEl = _elements
                                .cast<CustomElement?>()
                                .firstWhere(
                                  (e) => e?.id == _selectedElementId,
                                  orElse: () => null,
                                );

                            if (selectedEl != null) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          selectedEl.type ==
                                              CustomElementType.text
                                          ? const Color(0xFFF0F9FF)
                                          : const Color(0xFFFAF5FF),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          selectedEl.type ==
                                                  CustomElementType.text
                                              ? Icons.title_rounded
                                              : Icons.image_outlined,
                                          size: 15,
                                          color:
                                              selectedEl.type ==
                                                  CustomElementType.text
                                              ? const Color(0xFF0284C7)
                                              : const Color(0xFF7C3AED),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          selectedEl.type ==
                                                  CustomElementType.text
                                              ? 'Text'
                                              : 'Image',
                                          style: TextStyle(
                                            fontFamily: AuthTheme.fontFamily,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color:
                                                selectedEl.type ==
                                                    CustomElementType.text
                                                ? const Color(0xFF0284C7)
                                                : const Color(0xFF7C3AED),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // - search button (zoom out)
                                  Tooltip(
                                    message: 'Make smaller',
                                    child: InkWell(
                                      onTap: () => _zoomElement(
                                        selectedEl,
                                        zoomIn: false,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_out_rounded,
                                          color: Color(0xFF0F172A),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Scale indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 6,
                                    ),
                                    child: Text(
                                      '${(selectedEl.scale * 100).round()}%',
                                      style: const TextStyle(
                                        fontFamily: AuthTheme.fontFamily,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // + search button (zoom in)
                                  Tooltip(
                                    message: 'Make bigger',
                                    child: InkWell(
                                      onTap: () => _zoomElement(
                                        selectedEl,
                                        zoomIn: true,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: const Color(0xFFE2E8F0),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in_rounded,
                                          color: Color(0xFF0F172A),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                  const SizedBox(width: 6),

                                  // Delete
                                  Tooltip(
                                    message: 'Delete',
                                    child: InkWell(
                                      onTap: () =>
                                          _deleteElement(selectedEl.id),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFEF2F2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Color(0xFFEF4444),
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),

                                  // Done / Deselect button
                                  Tooltip(
                                    message: 'Done',
                                    child: InkWell(
                                      onTap: () => setState(
                                        () => _selectedElementId = null,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 19,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Visual Designer Feature Walkthrough Overlay (covers entire screen including AppBar)
          if (_showWalkthrough && _pdfPages.isNotEmpty)
            PreviewWalkthroughOverlay(
              steps: _buildWalkthroughSteps(),
              onDismiss: _dismissWalkthrough,
            ),
        ],
      ),
    );
  }

  Widget _buildPageCanvas(int pageIndex) {
    final imageSize = _imageSizes[pageIndex] ?? Size.zero;
    final pageElements = _elements
        .where((e) => e.pageIndex == pageIndex)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        // Page index label badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080F172A),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
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
        ),
        const SizedBox(height: 8),
        Center(
          child: Container(
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
                          behavior: HitTestBehavior.opaque,
                          onTap: () =>
                              setState(() => _selectedElementId = el.id),
                          onPanStart: (_) {
                            _saveSnapshot();
                          },
                          onPanUpdate: (details) {
                            setState(() {
                              _selectedElementId = el.id;
                              el.relativeX +=
                                  details.delta.dx / imageSize.width;
                              el.relativeY +=
                                  details.delta.dy / imageSize.height;
                              el.relativeX = el.relativeX.clamp(0.0, 1.0);
                              el.relativeY = el.relativeY.clamp(0.0, 1.0);
                            });
                          },
                          onLongPress: () => _showElementOptionsSheet(el),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              _buildElementWidget(el, imageSize),
                              if (isSelected)
                                Positioned(
                                  left: -2,
                                  top: -2,
                                  right: -2,
                                  bottom: -2,
                                  child: IgnorePointer(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: const Color(0xFF2563EB),
                                          width: 1.0,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
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
