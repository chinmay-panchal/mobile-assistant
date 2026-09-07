import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../services/book_service.dart';
import '../../../../services/paper_service.dart';
import '../../../../services/reference_paper_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';
import '../../../../services/api_client.dart';
import '../../books/screens/book_chapters_screen.dart';
import '../../paper_creation/screens/paper_result_screen.dart';
import '../../paper_creation/screens/pdf_preview_screen.dart';
import '../../paper_creation/screens/paper_wizard_screen.dart';

class SubjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> workspace;

  const SubjectDetailScreen({
    Key? key,
    required this.subject,
    required this.workspace,
  }) : super(key: key);

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final BookService _bookService = BookService();
  final PaperService _paperService = PaperService();
  final ReferencePaperService _refService = ReferencePaperService();
  
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _aiPapers = [];
  List<Map<String, dynamic>> _refPapers = [];
  
  bool _isLoading = true;
  bool _isLoadingPapers = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchBooks();
    _fetchPapers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _bookService.getBooks(widget.subject['id']);
      setState(() {
        _books = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndViewPdf(String urlPath, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ApiClient apiClient = ApiClient();
      final token = await apiClient.getAccessToken();
      
      final String fullUrl = urlPath.startsWith('http') 
          ? urlPath 
          : 'https://revisit-humongous-wiry.ngrok-free.dev$urlPath';
          
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bytes = response.bodyBytes;
        await Printing.layoutPdf(
          onLayout: (_) => bytes,
          name: '${title.replaceAll(' ', '_')}.pdf',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load PDF: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: $e')),
      );
    }
  }

  Future<void> _fetchPapers() async {
    setState(() => _isLoadingPapers = true);
    try {
      final results = await Future.wait([
        _refService.listReferencePapers(widget.subject['id']),
        _paperService.listPapersBySubject(widget.subject['id']),
      ]);
      final validAi = results[1].where((p) => p['status'] != 'FAILED').toList();
      if (mounted) {
        setState(() { 
          _refPapers = results[0];
          _aiPapers = validAi;
          _isLoadingPapers = false; 
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPapers = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.workspace['name'], style: theme.textTheme.bodySmall),
            Text(widget.subject['name'], style: theme.textTheme.titleLarge),
          ],
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: AppColors.primary,
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textTertiary,
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 16),
                          SizedBox(width: 8),
                          Text('Books', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insert_drive_file_outlined, size: 16),
                          SizedBox(width: 8),
                          Text('Papers', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBooksTab(),
                    _buildPapersTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBooksTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: AppColors.error)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchBooks,
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _books.length + 1,
      itemBuilder: (context, index) {
        if (index == _books.length) {
          return GestureDetector(
            onTap: () {
              AppBottomSheet.showAddBook(
                context,
                subjectId: widget.subject['id'],
                onSuccess: _fetchBooks,
              );
            },
            child: _DashedBorderBox(
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.primary),
                  SizedBox(width: 8),
                  Text('Add Book', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          );
        }

        final book = _books[index];

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BookChaptersScreen(book: book, subject: widget.subject),
              ),
            ).then((_) => _fetchBooks());
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
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
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: const Icon(Icons.menu_book, color: AppColors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    book['title'] ?? book['name'] ?? 'Untitled Book',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.textTertiary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  onSelected: (val) {
                    if (val == 'edit') {
                      AppBottomSheet.showEditBook(
                        context,
                        book: book,
                        onSuccess: _fetchBooks,
                      );
                    } else if (val == 'delete') {
                      AppBottomSheet.showDeleteConfirm(
                        context,
                        title: 'Delete Book',
                        message: 'Are you sure you want to delete "${book['name'] ?? book['title']}"? All chapters and uploaded files inside will be deleted.',
                        onDelete: () async {
                          await _bookService.deleteBook(book['id']);
                          _fetchBooks();
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
                          Text('Edit Book'),
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
                const Icon(Icons.chevron_right, color: AppColors.textTertiary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPapersTab() {
    final List<Map<String, dynamic>> combinedList = [
      ..._aiPapers.map((p) => {...p, 'is_ai': true}),
      ..._refPapers.map((p) => {...p, 'is_ai': false}),
    ];

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PaperWizardScreen(subject: widget.subject),
                ),
              ).then((_) => _fetchPapers()); // Refresh papers on return
            },
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: const Text('Create Paper with AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _isLoadingPapers
              ? const Center(child: CircularProgressIndicator())
              : combinedList.isEmpty
                  ? const Center(
                      child: Text(
                        'No papers yet.\nTap "Create Paper with AI" above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      itemCount: combinedList.length,
                      itemBuilder: (context, index) {
                        final paper = combinedList[index];
                        final isAi = paper['is_ai'] == true;

                        return GestureDetector(
                          onTap: () async {
                            if (isAi && (paper['pdf_url'] == null || paper['pdf_url'].toString().isEmpty)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PdfPreviewScreen(
                                    subject: widget.subject,
                                    paper: paper,
                                    isReadOnly: true,
                                  ),
                                ),
                              ).then((_) => _fetchPapers());
                            } else {
                              final urlPath = isAi ? paper['pdf_url'] : paper['file_url'];
                              if (urlPath != null) {
                                await _downloadAndViewPdf(urlPath.toString(), paper['title'] ?? 'paper');
                              }
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(20),
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
                                CircleAvatar(
                                  backgroundColor: isAi ? AppColors.primary.withOpacity(0.1) : AppColors.divider.withOpacity(0.4),
                                  child: Icon(isAi ? Icons.auto_awesome : Icons.insert_drive_file_outlined, 
                                    color: isAi ? AppColors.primary : AppColors.textTertiary),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paper['title'] ?? (isAi ? 'Generated Paper' : 'Reference Paper'),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 4),
                                      if (isAi)
                                        Text(
                                          '${paper['total_marks'] ?? 0} marks',
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        )
                                      else
                                        Row(children: [
                                          if (paper['year'] != null) ...[
                                            Text('${paper['year']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                            const Padding(padding: EdgeInsets.symmetric(horizontal: 4), child: Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
                                          ],
                                          if (paper['exam_type'] != null)
                                            Text('${paper['exam_type']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                        ]),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isAi)
                                      IconButton(
                                        icon: const Icon(Icons.remove_red_eye, color: AppColors.textSecondary),
                                        onPressed: () async {
                                          final urlPath = paper['file_url'];
                                          if (urlPath != null) {
                                            await _downloadAndViewPdf(urlPath.toString(), paper['title'] ?? 'paper');
                                          }
                                        },
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                      onPressed: () {
                                        AppBottomSheet.showDeleteConfirm(
                                          context,
                                          title: isAi ? 'Delete Paper' : 'Delete Reference Paper',
                                          message: 'Are you sure you want to delete "${paper['title'] ?? 'this paper'}"?',
                                          onDelete: () async {
                                            if (isAi) {
                                              await _paperService.deletePaper(paper['id']);
                                            } else {
                                              await _refService.deleteReferencePaper(paper['id']);
                                            }
                                            _fetchPapers();
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
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
