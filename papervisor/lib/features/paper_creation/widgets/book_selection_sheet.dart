import 'package:flutter/material.dart';
import '../../../core/utils/pdf_preview_helper.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Modal bottom sheet allowing users to select an uploaded book across all workspaces
/// to start generating an exam paper with AI. Includes in-app PDF preview.
class BookSelectionSheet extends StatefulWidget {
  final List<Map<String, dynamic>> books;
  final ValueChanged<Map<String, dynamic>> onSelect;

  const BookSelectionSheet({
    super.key,
    required this.books,
    required this.onSelect,
  });

  static Future<void> show({
    required BuildContext context,
    required List<Map<String, dynamic>> books,
    required ValueChanged<Map<String, dynamic>> onSelect,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => BookSelectionSheet(books: books, onSelect: onSelect),
    );
  }

  @override
  State<BookSelectionSheet> createState() => _BookSelectionSheetState();
}

class _BookSelectionSheetState extends State<BookSelectionSheet> {
  String? _selectedBookId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.books.isNotEmpty) {
      _selectedBookId = widget.books.first['id']?.toString();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredBooks {
    if (_searchQuery.trim().isEmpty) return widget.books;
    final query = _searchQuery.toLowerCase().trim();
    return widget.books.where((b) {
      final name = (b['name'] ?? b['title'] ?? '').toString().toLowerCase();
      final subject = (b['subject']?['name'] ?? '').toString().toLowerCase();
      final workspace = (b['workspace']?['name'] ?? '').toString().toLowerCase();
      return name.contains(query) || subject.contains(query) || workspace.contains(query);
    }).toList();
  }

  String? _getPreviewUrl(Map<String, dynamic> book) {
    if (book['pdf_url'] != null && book['pdf_url'].toString().isNotEmpty) {
      return book['pdf_url'].toString();
    }
    // Check chapter-level PDF
    final chapters = book['chapters'] as List<dynamic>?;
    if (chapters != null && chapters.isNotEmpty) {
      for (final ch in chapters) {
        if (ch is Map && ch['pdf_url'] != null && ch['pdf_url'].toString().isNotEmpty) {
          return ch['pdf_url'].toString();
        }
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final filtered = _filteredBooks;
    final selectedBook = widget.books.cast<Map<String, dynamic>?>().firstWhere(
      (b) => b?['id']?.toString() == _selectedBookId,
      orElse: () => null,
    );

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottomInset + 16),
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
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Subtitle
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: AuthTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Source Book',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AuthTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choose a book to generate examination questions from',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12,
                          color: AuthTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Bar (if more than 3 books)
            if (widget.books.length > 3) ...[
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AuthTheme.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Search by book, subject, or workspace…',
                  hintStyle: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AuthTheme.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Books List
            Flexible(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          _searchQuery.isEmpty ? 'No books available.' : 'No books matched "$_searchQuery".',
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            color: AuthTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final book = filtered[index];
                        final bookId = book['id']?.toString() ?? '';
                        final isSelected = _selectedBookId == bookId;
                        final bookName = (book['name'] ?? book['title'] ?? 'Untitled Book').toString();
                        final subjectName = (book['subject']?['name'] ?? '').toString();
                        final workspaceName = (book['workspace']?['name'] ?? '').toString();
                        final chapters = book['chapters'] as List<dynamic>? ?? [];
                        final previewUrl = _getPreviewUrl(book);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFFF8FAFC) : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? AuthTheme.primary : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isSelected
                                    ? AuthTheme.primary.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.02),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => setState(() => _selectedBookId = bookId),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Book Icon
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFFBAE6FD) : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.menu_book_rounded,
                                        color: isSelected ? AuthTheme.primary : const Color(0xFF64748B),
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Book Info & Tags
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bookName.toUpperCase(),
                                            style: TextStyle(
                                              fontFamily: AuthTheme.fontFamily,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isSelected ? AuthTheme.primary : AuthTheme.textPrimary,
                                              letterSpacing: -0.2,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              if (subjectName.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFEFF6FF),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    subjectName.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontFamily: AuthTheme.fontFamily,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: Color(0xFF0284C7),
                                                    ),
                                                  ),
                                                ),
                                              if (workspaceName.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF1F5F9),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    workspaceName.toUpperCase(),
                                                    style: const TextStyle(
                                                      fontFamily: AuthTheme.fontFamily,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: AuthTheme.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              if (chapters.isNotEmpty)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color(0xFFF8FAFC),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                                  ),
                                                  child: Text(
                                                    '${chapters.length} Ch.',
                                                    style: const TextStyle(
                                                      fontFamily: AuthTheme.fontFamily,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w600,
                                                      color: AuthTheme.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Preview Button (In-App PDF Viewer)
                                    if (previewUrl != null)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.visibility_outlined,
                                          size: 20,
                                          color: AuthTheme.textPrimary,
                                        ),
                                        tooltip: 'Preview Book PDF',
                                        onPressed: () {
                                          PdfPreviewHelper.openRemotePdf(
                                            context,
                                            urlPath: previewUrl,
                                            title: bookName,
                                          );
                                        },
                                      ),

                                    const SizedBox(width: 4),

                                    // Selection Radio Indicator
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isSelected ? AuthTheme.primary : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected ? AuthTheme.primary : const Color(0xFFCBD5E1),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: isSelected
                                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                                          : null,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 14),

            // Bottom Continue CTA
            AuthPrimaryButton(
              text: 'Continue to Step 1',
              height: 50,
              onPressed: selectedBook != null
                  ? () {
                      Navigator.pop(context);
                      widget.onSelect(selectedBook);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
