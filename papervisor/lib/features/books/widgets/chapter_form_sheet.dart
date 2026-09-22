import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Bottom sheet for adding or editing a chapter.
class ChapterFormSheet extends StatefulWidget {
  final String? initialTitle;
  final int? initialChapterNumber;
  final int? initialStartPage;
  final int? initialEndPage;
  final bool hasWholeBookPdf;
  final bool isEditing;
  final Future<void> Function({
    required int chapterNumber,
    required String title,
    int? startPage,
    int? endPage,
    PlatformFile? selectedPdfFile,
  }) onSubmit;

  const ChapterFormSheet({
    super.key,
    this.initialTitle,
    this.initialChapterNumber,
    this.initialStartPage,
    this.initialEndPage,
    required this.hasWholeBookPdf,
    this.isEditing = false,
    required this.onSubmit,
  });

  static Future<void> showAdd({
    required BuildContext context,
    required int nextChapterNum,
    required bool hasWholeBookPdf,
    required Future<void> Function({
      required int chapterNumber,
      required String title,
      int? startPage,
      int? endPage,
      PlatformFile? selectedPdfFile,
    }) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChapterFormSheet(
        initialChapterNumber: nextChapterNum,
        hasWholeBookPdf: hasWholeBookPdf,
        isEditing: false,
        onSubmit: onSubmit,
      ),
    );
  }

  static Future<void> showEdit({
    required BuildContext context,
    required Map<String, dynamic> chapter,
    required bool hasWholeBookPdf,
    required Future<void> Function({
      required int chapterNumber,
      required String title,
      int? startPage,
      int? endPage,
      PlatformFile? selectedPdfFile,
    }) onSubmit,
  }) {
    final rawNum = chapter['chapter_number'];
    final chapterNum = rawNum is num ? rawNum.toInt() : int.tryParse(rawNum?.toString() ?? '');
    final startPage = chapter['start_page'] is num
        ? (chapter['start_page'] as num).toInt()
        : int.tryParse(chapter['start_page']?.toString() ?? '');
    final endPage = chapter['end_page'] is num
        ? (chapter['end_page'] as num).toInt()
        : int.tryParse(chapter['end_page']?.toString() ?? '');

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChapterFormSheet(
        initialTitle: (chapter['name'] ?? chapter['title'] ?? '').toString(),
        initialChapterNumber: chapterNum,
        initialStartPage: startPage,
        initialEndPage: endPage,
        hasWholeBookPdf: hasWholeBookPdf,
        isEditing: true,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<ChapterFormSheet> createState() => _ChapterFormSheetState();
}

class _ChapterFormSheetState extends State<ChapterFormSheet> {
  late TextEditingController _numberCtrl;
  late TextEditingController _titleCtrl;
  late TextEditingController _startPageCtrl;
  late TextEditingController _endPageCtrl;

  PlatformFile? _selectedPdfFile;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController(
      text: widget.initialChapterNumber?.toString() ?? '',
    );
    _titleCtrl = TextEditingController(text: widget.initialTitle ?? '');
    _startPageCtrl = TextEditingController(
      text: widget.initialStartPage?.toString() ?? '',
    );
    _endPageCtrl = TextEditingController(
      text: widget.initialEndPage?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _titleCtrl.dispose();
    _startPageCtrl.dispose();
    _endPageCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickChapterPdf() async {
    try {
      final res = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (res.isNotEmpty) {
        setState(() {
          _selectedPdfFile = res.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select PDF: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    final title = _titleCtrl.text.trim();
    final numberStr = _numberCtrl.text.trim();

    if (title.isEmpty) {
      setState(() => _errorMessage = 'Please enter a chapter name');
      return;
    }
    if (numberStr.isEmpty) {
      setState(() => _errorMessage = 'Please enter a chapter number');
      return;
    }

    final chapterNum = int.tryParse(numberStr) ?? (widget.initialChapterNumber ?? 1);
    final startPage = int.tryParse(_startPageCtrl.text.trim());
    final endPage = int.tryParse(_endPageCtrl.text.trim());

    if (widget.hasWholeBookPdf) {
      if (startPage == null) {
        setState(() => _errorMessage = 'Please enter a start page');
        return;
      }
      if (endPage == null) {
        setState(() => _errorMessage = 'Please enter an end page');
        return;
      }
      if (endPage < startPage) {
        setState(() => _errorMessage = 'End page cannot be less than start page');
        return;
      }
    } else {
      if (!widget.isEditing && _selectedPdfFile == null) {
        setState(() => _errorMessage = 'Please upload a chapter PDF');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onSubmit(
        chapterNumber: chapterNum,
        title: title,
        startPage: widget.hasWholeBookPdf ? startPage : null,
        endPage: widget.hasWholeBookPdf ? endPage : null,
        selectedPdfFile: widget.hasWholeBookPdf ? null : _selectedPdfFile,
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 26,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
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
              const SizedBox(height: 18),

              // Sheet Header
              Text(
                widget.isEditing ? 'Edit Chapter' : 'Add Chapter',
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AuthTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.isEditing
                    ? 'Update chapter number, name, and details.'
                    : widget.hasWholeBookPdf
                        ? 'Enter chapter details and page range from the book.'
                        : 'Enter chapter details and upload the chapter PDF.',
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AuthTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Error banner if any
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AuthTheme.errorLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AuthTheme.errorBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: AuthTheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            color: AuthTheme.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Chapter Number Input
              _buildLabeledField(
                label: 'Chapter Number',
                controller: _numberCtrl,
                hintText: 'e.g. 1',
                icon: Icons.tag_rounded,
                isNumber: true,
              ),
              const SizedBox(height: 14),

              // Chapter Name Input
              _buildLabeledField(
                label: 'Chapter Name',
                controller: _titleCtrl,
                hintText: 'e.g. Chemical Reactions and Equations',
                icon: Icons.menu_book_outlined,
              ),
              const SizedBox(height: 14),

              // Conditional Page Range Fields (ONLY shown when whole book PDF is uploaded)
              if (widget.hasWholeBookPdf) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildLabeledField(
                        label: 'Start Page',
                        controller: _startPageCtrl,
                        hintText: 'e.g. 1',
                        icon: Icons.first_page_rounded,
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildLabeledField(
                        label: 'End Page',
                        controller: _endPageCtrl,
                        hintText: 'e.g. 24',
                        icon: Icons.last_page_rounded,
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
              ]
              // Conditional Chapter PDF Upload (ONLY shown when whole book PDF is NOT uploaded and not editing)
              else if (!widget.isEditing) ...[
                const Text(
                  'Chapter PDF',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),

                // Upload Card / Selected File Card
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickChapterPdf,
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: _selectedPdfFile != null
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _selectedPdfFile != null
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _selectedPdfFile != null
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _selectedPdfFile != null
                                  ? Icons.check_circle_rounded
                                  : Icons.upload_file_rounded,
                              color: _selectedPdfFile != null
                                  ? const Color(0xFF059669)
                                  : AuthTheme.primary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPdfFile != null
                                      ? _selectedPdfFile!.name
                                      : 'Upload Chapter PDF',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: _selectedPdfFile != null
                                        ? const Color(0xFF065F46)
                                        : AuthTheme.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _selectedPdfFile != null
                                      ? 'PDF selected · Tap to change'
                                      : 'Supports standard PDF documents',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 11,
                                    color: _selectedPdfFile != null
                                        ? const Color(0xFF047857)
                                        : AuthTheme.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_selectedPdfFile != null)
                            IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: AuthTheme.textTertiary,
                              ),
                              onPressed: () => setState(() => _selectedPdfFile = null),
                              tooltip: 'Remove selected PDF',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ] else ...[
                const SizedBox(height: 8),
              ],

              // Actions: Cancel & Submit
              Row(
                children: [
                  Expanded(
                    child: AuthPrimaryButton(
                      text: 'Cancel',
                      isSecondary: true,
                      height: 44,
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthPrimaryButton(
                      text: widget.isEditing ? 'Save Changes' : 'Add Chapter',
                      height: 44,
                      isLoading: _isLoading,
                      onPressed: _handleSubmit,
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

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AuthTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: const TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AuthTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 13,
              color: AuthTheme.textTertiary,
            ),
            prefixIcon: Icon(icon, size: 18, color: AuthTheme.textTertiary),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AuthTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
