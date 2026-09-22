import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../services/book_service.dart';
import '../../../../services/chapter_service.dart';
import '../../../../services/document_service.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../widgets/add_chapter_tile.dart';
import '../widgets/book_header.dart';
import '../widgets/book_pdf_card.dart';
import '../widgets/chapter_card.dart';
import '../widgets/chapter_delete_dialog.dart';
import '../widgets/chapter_empty_state.dart';
import '../widgets/chapter_form_sheet.dart';
import '../widgets/chapter_loading_state.dart';

class BookChaptersScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final Map<String, dynamic> subject;

  const BookChaptersScreen({
    super.key,
    required this.book,
    required this.subject,
  });

  @override
  State<BookChaptersScreen> createState() => _BookChaptersScreenState();
}

class _BookChaptersScreenState extends State<BookChaptersScreen> {
  final ChapterService _chapterService = ChapterService();
  final DocumentService _documentService = DocumentService();
  final BookService _bookService = BookService();
  List<Map<String, dynamic>> _chapters = [];
  late Map<String, dynamic> _bookData;
  bool _isLoading = true;
  String? _error;

  // Tracks book-level uploaded documents (not chapter-specific)
  final List<Map<String, dynamic>> _bookDocuments = [];
  // Active polling timers keyed by document id
  final Map<String, Timer> _pollingTimers = {};
  // Consecutive network error counts per document id
  final Map<String, int> _pollErrorCounts = {};

  @override
  void initState() {
    super.initState();
    _bookData = Map<String, dynamic>.from(widget.book);
    _fetchChapters();
    _fetchBook(); // ensure we have latest book data
  }

  @override
  void dispose() {
    for (final t in _pollingTimers.values) {
      t.cancel();
    }
    _pollingTimers.clear();
    _pollErrorCounts.clear();
    super.dispose();
  }

  /// Polls document status every 4s until READY or FAILED.
  void _startPolling(String docId) {
    _pollingTimers[docId]?.cancel();
    _pollErrorCounts[docId] = 0;
    _pollingTimers[docId] = Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        final updated = await _documentService.getDocumentStatus(docId);
        _pollErrorCounts[docId] = 0;

        String status = (updated['processing_status'] ?? '').toString().toUpperCase();

        // Auto-fail after 15 minutes of non-terminal status
        final createdAtStr = updated['created_at'];
        if (createdAtStr != null) {
          final createdAt = DateTime.tryParse(createdAtStr);
          if (createdAt != null && status != 'READY' && status != 'FAILED') {
            if (DateTime.now().toUtc().difference(createdAt).inMinutes > 15) {
              status = 'FAILED';
            }
          }
        }

        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          final idx = _bookDocuments.indexWhere((d) => d['id'] == docId);
          if (idx != -1) {
            _bookDocuments[idx] = {..._bookDocuments[idx], 'status': status};
          }
        });
        if (status == 'READY' || status == 'FAILED') {
          timer.cancel();
          _pollingTimers.remove(docId);
          _pollErrorCounts.remove(docId);
          if (status == 'READY') {
            _fetchBook();
            _fetchChapters();
          }
        }
      } catch (_) {
        final errors = (_pollErrorCounts[docId] ?? 0) + 1;
        _pollErrorCounts[docId] = errors;

        if (errors >= 20) {
          timer.cancel();
          _pollingTimers.remove(docId);
          _pollErrorCounts.remove(docId);
        }
      }
    });
  }

  Future<void> _fetchChapters() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _chapterService.getChapters(widget.book['id']);
      if (mounted) {
        setState(() {
          _chapters = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchBook() async {
    try {
      final updatedBook = await _bookService.getBook(widget.book['id']);
      final docs = await _documentService.getDocumentsForBook(widget.book['id']);

      if (mounted) {
        setState(() {
          _bookData = updatedBook;

          if (docs.isNotEmpty && _bookDocuments.isEmpty) {
            final doc = docs.first;
            String status = doc['processing_status'] ?? 'READY';

            final createdAtStr = doc['created_at'];
            if (createdAtStr != null) {
              final createdAt = DateTime.tryParse(createdAtStr);
              if (createdAt != null && status != 'READY' && status != 'FAILED') {
                if (DateTime.now().toUtc().difference(createdAt).inMinutes > 15) {
                  status = 'FAILED';
                }
              }
            }

            _bookDocuments.add({
              'id': doc['id'],
              'filename': doc['original_filename'] ?? 'Book PDF',
              'status': status,
              'file_url': doc['file_url'],
            });
            if (status != 'READY' && status != 'FAILED') {
              _startPolling(doc['id']);
            }
          }
        });
      }
    } catch (_) {
      // silently fail, we still have initial book data
    }
  }

  Future<void> _openPdfUrl(String? urlPath) async {
    if (urlPath == null) return;
    final uri = Uri.parse('https://revisit-humongous-wiry.ngrok-free.dev$urlPath');
    try {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AuthTheme.error,
            content: Text(
              'Could not open PDF preview: $e',
              style: const TextStyle(fontFamily: AuthTheme.fontFamily),
            ),
          ),
        );
      }
    }
  }

  Future<void> _uploadWholeBook() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result.isNotEmpty) {
        final picked = result.first;
        if (picked.path == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Could not access file. Please try again.'),
              ),
            );
          }
          return;
        }
        setState(() => _isLoading = true);

        final doc = await _documentService.uploadDocument(
          filePath: picked.path!,
          bookId: widget.book['id'],
        );

        if (mounted) {
          final docId = doc['id'] as String;
          setState(() {
            _isLoading = false;
            _bookDocuments.add({
              'id': docId,
              'filename': picked.name,
              'status': 'UPLOADED',
              'file_url': '/storage/documents/$docId/original.pdf',
            });
          });
          _startPolling(docId);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              backgroundColor: AuthTheme.primary,
              content: const Text(
                'Book PDF uploaded — processing…',
                style: TextStyle(fontFamily: AuthTheme.fontFamily),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AuthTheme.error,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: AuthTheme.fontFamily),
            ),
          ),
        );
      }
    }
  }

  void _openAddChapterSheet() {
    ChapterFormSheet.showAdd(
      context: context,
      nextChapterNum: _chapters.length + 1,
      hasWholeBookPdf: _bookDocuments.isNotEmpty,
      onSubmit: ({
        required int chapterNumber,
        required String title,
        int? startPage,
        int? endPage,
        PlatformFile? selectedPdfFile,
      }) async {
        final chapter = await _chapterService.createChapter(
          widget.book['id'],
          chapterNumber,
          title,
          startPage: startPage,
          endPage: endPage,
        );
        if (selectedPdfFile != null && selectedPdfFile.path != null) {
          await _documentService.uploadDocument(
            filePath: selectedPdfFile.path!,
            bookId: widget.book['id'],
            chapterId: chapter['id'],
          );
        }
        _fetchChapters();
      },
    );
  }

  void _openEditChapterSheet(Map<String, dynamic> chapter) {
    ChapterFormSheet.showEdit(
      context: context,
      chapter: chapter,
      hasWholeBookPdf: _bookDocuments.isNotEmpty,
      onSubmit: ({
        required int chapterNumber,
        required String title,
        int? startPage,
        int? endPage,
        PlatformFile? selectedPdfFile,
      }) async {
        await _chapterService.updateChapter(
          chapter['id'],
          chapterNumber,
          title,
          startPage: startPage,
          endPage: endPage,
        );
        _fetchChapters();
      },
    );
  }

  void _confirmDeleteChapter(Map<String, dynamic> chapter) {
    final rawChapterNum = chapter['chapter_number'];
    final chapterNum = rawChapterNum != null ? rawChapterNum.toString() : '';
    final chapterTitle = (chapter['name'] ?? chapter['title'] ?? 'Chapter').toString();

    ChapterDeleteDialog.show(
      context: context,
      chapterNumber: chapterNum,
      chapterName: chapterTitle,
      onConfirmDelete: () async {
        await _chapterService.deleteChapter(chapter['id']);
        _fetchChapters();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookTitle = (_bookData['title'] ?? _bookData['name'] ?? 'Book Chapters').toString();
    final subjectName = (widget.subject['name'] ?? 'Subject').toString();
    final hasBookPdf = _bookDocuments.isNotEmpty && _bookDocuments.first['file_url'] != null;

    return Scaffold(
      backgroundColor: AuthTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Modern Header
            BookHeader(
              bookTitle: bookTitle,
              subjectName: subjectName,
              chapterCount: _chapters.length,
              onBack: () => Navigator.pop(context),
              onPreviewBook: hasBookPdf
                  ? () => _openPdfUrl(_bookDocuments.first['file_url'])
                  : null,
            ),

            // Content Area
            Expanded(
              child: _isLoading
                  ? const ChapterLoadingState()
                  : _error != null
                      ? _buildErrorState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            await Future.wait([_fetchChapters(), _fetchBook()]);
                          },
                          color: AuthTheme.primary,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: [
                              // ── 1. Book PDF Card (Uploaded or Upload CTA) ──
                              BookPdfCard(
                                document: _bookDocuments.isNotEmpty
                                    ? _bookDocuments.first
                                    : null,
                                onPreview: hasBookPdf
                                    ? () => _openPdfUrl(_bookDocuments.first['file_url'])
                                    : null,
                                onUpload: _uploadWholeBook,
                              ),
                              const SizedBox(height: 22),

                              // ── 2. Section Header: Chapters ──
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Chapters',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AuthTheme.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: Text(
                                      '${_chapters.length} ${_chapters.length == 1 ? "chapter" : "chapters"}',
                                      style: const TextStyle(
                                        fontFamily: AuthTheme.fontFamily,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AuthTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // ── 3. Chapter Cards or Empty State ──
                              if (_chapters.isEmpty) ...[
                                const ChapterEmptyState(),
                              ] else ...[
                                ..._chapters.map((chapter) {
                                  return ChapterCard(
                                    chapter: chapter,
                                    onEdit: () => _openEditChapterSheet(chapter),
                                    onDelete: () => _confirmDeleteChapter(chapter),
                                    onPreviewPdf: chapter['file_url'] != null
                                        ? () => _openPdfUrl(chapter['file_url'])
                                        : null,
                                  );
                                }),
                                const SizedBox(height: 10),

                                // ── 4. Add Chapter Action Box at list end ──
                                if (_pollingTimers.isEmpty)
                                  AddChapterTile(
                                    onTap: _openAddChapterSheet,
                                  ),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildAddChapterFab(),
    );
  }

  Widget _buildAddChapterFab() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
        gradient: AuthTheme.primaryGradient,
        boxShadow: AuthTheme.buttonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
          onTap: _openAddChapterSheet,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  'Add Chapter',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AuthTheme.errorLight,
                shape: BoxShape.circle,
                border: Border.all(color: AuthTheme.errorBorder),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AuthTheme.error,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Couldn\'t load chapters',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AuthTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _error ?? 'Something went wrong while loading chapters.',
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                color: AuthTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              child: AuthPrimaryButton(
                text: 'Try Again',
                height: 42,
                onPressed: _fetchChapters,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
