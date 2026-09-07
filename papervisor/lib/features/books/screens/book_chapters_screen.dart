import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../services/chapter_service.dart';
import '../../../../services/document_service.dart';
import '../../../../services/book_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';

class BookChaptersScreen extends StatefulWidget {
  final Map<String, dynamic> book;
  final Map<String, dynamic> subject;

  const BookChaptersScreen({
    Key? key,
    required this.book,
    required this.subject,
  }) : super(key: key);

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
    super.dispose();
  }

  /// Polls document status every 3s until READY or FAILED.
  void _startPolling(String docId) {
    _pollingTimers[docId]?.cancel();
    _pollingTimers[docId] = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final updated = await _documentService.getDocumentStatus(docId);
        String status = (updated['processing_status'] ?? '').toString().toUpperCase();
        
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
          if (status == 'READY') {
            _fetchBook();
            _fetchChapters();
          }
        }
      } catch (e) {
        timer.cancel();
        _pollingTimers.remove(docId);
        if (mounted) {
          setState(() {
            final idx = _bookDocuments.indexWhere((d) => d['id'] == docId);
            if (idx != -1) {
              _bookDocuments[idx] = {..._bookDocuments[idx], 'status': 'FAILED'};
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Processing failed: $e'.replaceAll('Exception: ', ''))),
          );
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
      setState(() {
        _chapters = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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
      // silently fail, we still have the initial book data
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
          SnackBar(content: Text('Could not open PDF preview: $e')),
        );
      }
    }
  }

  Future<void> _uploadWholeBook() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: false,
        withReadStream: false,
      );

      if (result.isNotEmpty) {
        final picked = result.first;
        if (picked.path == null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not access file. Please try again.')),
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
          // Start polling until READY
          _startPolling(docId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Book PDF uploaded — processing…')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bookTitle = widget.book['title'] ?? widget.book['name'] ?? 'Book Chapters';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.subject['name'], style: theme.textTheme.bodySmall),
            Text(bookTitle, style: theme.textTheme.titleLarge),
          ],
        ),
        centerTitle: false,
        actions: [
          if (!_isLoading && _bookDocuments.isNotEmpty && _bookDocuments.first['file_url'] != null)
            IconButton(
              icon: const Icon(Icons.remove_red_eye),
              onPressed: () => _openPdfUrl(_bookDocuments.first['file_url']),
              tooltip: 'Preview Whole Book',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_error!, style: const TextStyle(color: AppColors.error)),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _fetchChapters,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        // ── Book-level PDFs section ──
                        if (_bookDocuments.isNotEmpty) ...[
                          _sectionHeader(Icons.menu_book_outlined, 'Book PDF'),
                          const SizedBox(height: 8),
                          ..._bookDocuments.map((doc) => _buildDocumentCard(doc)),
                          const SizedBox(height: 24),
                        ],

                        // ── Chapters section ──
                        if (_chapters.isNotEmpty) ...[
                          _sectionHeader(Icons.list_alt_outlined, 'Chapters'),
                          const SizedBox(height: 8),
                          ..._chapters.asMap().entries.map((entry) {
                            return _buildChapterCard(entry.value);
                          }),
                          const SizedBox(height: 16),
                        ],

                        // ── Empty state ──
                        if (_bookDocuments.isEmpty && _chapters.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                Icon(Icons.menu_book_outlined, size: 56, color: AppColors.textTertiary.withOpacity(0.4)),
                                const SizedBox(height: 12),
                                Text(
                                  'No content yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Upload the whole book PDF or add chapters below.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppColors.textTertiary, fontSize: 13),
                                ),
                              ],
                            ),
                          ),

                        // ── Action buttons ──
                        if (_bookDocuments.isEmpty)
                          _buildActionButton(
                            icon: Icons.upload_file,
                            label: 'Upload Whole Book PDF',
                            onTap: _uploadWholeBook,
                          ),
                        const SizedBox(height: 12),
                        _buildActionButton(
                          icon: Icons.add,
                          label: 'Add Chapter',
                          onTap: () {
                            AppBottomSheet.showAddChapter(
                              context,
                              bookId: widget.book['id'],
                              nextChapterNum: _chapters.length + 1,
                              hasWholeBookPdf: _bookDocuments.isNotEmpty,
                              onSuccess: _fetchChapters,
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _sectionHeader(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textTertiary,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard(Map<String, dynamic> doc) {
    final status = (doc['status'] ?? '').toString().toUpperCase();
    final isReady = status == 'READY';
    final isProcessing = status == 'PROCESSING' || status == 'UPLOADED' || status == 'EMBEDDING';
    final color = isReady ? AppColors.success : (isProcessing ? AppColors.warning : AppColors.textTertiary);
    final bgColor = isReady ? AppColors.successLight : (isProcessing ? AppColors.warningLight : AppColors.background);
    
    double progress = 0.0;
    if (status == 'UPLOADED') progress = 0.25;
    else if (status == 'PROCESSING') progress = 0.50;
    else if (status == 'EMBEDDING') progress = 0.75;
    else if (status == 'READY') progress = 1.0;

    final statusLabel = isReady
        ? '✓ Ready'
        : status == 'UPLOADED'
            ? '⏫ Uploading…'
            : status == 'PROCESSING'
                ? '⚙ Extracting pages…'
                : status == 'EMBEDDING'
                    ? '🔗 Generating embeddings…'
                    : status == 'FAILED'
                        ? '✕ Failed'
                        : 'Processing…';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.divider.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: bgColor,
                radius: 20,
                child: Icon(
                  isReady ? Icons.check_circle_outline : (isProcessing ? Icons.hourglass_top : Icons.picture_as_pdf),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc['filename'] ?? 'Book PDF',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.picture_as_pdf, color: AppColors.textTertiary, size: 20),
            ],
          ),
          if (progress > 0.0 && progress < 1.0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChapterCard(Map<String, dynamic> chapter) {
    final chapterNum = chapter['chapter_number'] ?? '?';
    final chapterTitle = chapter['name'] ?? chapter['title'] ?? 'Untitled Chapter';
    // Backend doesn't track chapter document status in chapter object directly,
    // so we show upload button always (unless we track locally)
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.divider.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Chapter number badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$chapterNum',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  chapterTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  chapter['start_page'] != null && chapter['end_page'] != null
                      ? 'Pages: ${chapter['start_page']}–${chapter['end_page']}'
                      : 'Chapter $chapterNum',
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ],
            ),
          ),
          // Upload or Preview PDF button for chapter
          if (chapter['file_url'] != null) ...[
            GestureDetector(
              onTap: () => _openPdfUrl(chapter['file_url']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.remove_red_eye, size: 13, color: AppColors.success),
                    SizedBox(width: 4),
                    Text(
                      'Preview',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textTertiary),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (val) {
              if (val == 'edit') {
                AppBottomSheet.showEditChapter(
                  context,
                  chapter: chapter,
                  hasWholeBookPdf: _bookDocuments.isNotEmpty,
                  onSuccess: _fetchChapters,
                );
              } else if (val == 'delete') {
                AppBottomSheet.showDeleteConfirm(
                  context,
                  title: 'Delete Chapter',
                  message: 'Are you sure you want to delete Chapter $chapterNum ("$chapterTitle")?',
                  onDelete: () async {
                    await _chapterService.deleteChapter(chapter['id']);
                    _fetchChapters();
                  },
                );
              }
            },
            itemBuilder: (ctx) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                    SizedBox(width: 8),
                    Text('Edit Chapter'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _DashedBorderBox(
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

/// Dashed rounded-border box using CustomPaint.
class _DashedBorderBox extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  const _DashedBorderBox({
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.divider,
    this.strokeWidth = 1.5,
    this.dashLength = 6,
    this.dashGap = 4,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        borderRadius: borderRadius,
        color: color,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        dashGap: dashGap,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  _DashedBorderPainter({
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.borderRadius != borderRadius;
}

