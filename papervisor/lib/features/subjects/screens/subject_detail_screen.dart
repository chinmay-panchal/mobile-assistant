import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../../core/utils/responsive.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../../../../services/api_client.dart';
import '../../../../services/book_service.dart';
import '../../../../services/paper_service.dart';
import '../../../../services/reference_paper_service.dart';
import '../../books/screens/book_chapters_screen.dart';
import '../../paper_creation/screens/paper_wizard_screen.dart';
import '../../paper_creation/screens/pdf_preview_screen.dart';
import '../../paper_creation/screens/saved_pdf_viewer_screen.dart';
import '../constants/subject_detail_assets.dart';
import '../widgets/add_book_tile.dart';
import '../widgets/book_card.dart';
import '../widgets/book_delete_dialog.dart';
import '../widgets/book_form_sheet.dart';
import '../widgets/detail_empty_state.dart';
import '../widgets/detail_loading_state.dart';
import '../widgets/paper_card.dart';
import '../widgets/paper_delete_dialog.dart';
import '../widgets/subject_detail_header.dart';
import '../widgets/subject_detail_tabs.dart';

/// Redesigned SubjectDetailScreen matching the Papervisor pastel design system.
/// Features a workspace/subject contextual header, segmented Books & Papers tabs,
/// lightweight skeleton loading, tactile cards, contextual menus, and bottom sheets.
class SubjectDetailScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> workspace;

  const SubjectDetailScreen({
    super.key,
    required this.subject,
    required this.workspace,
  });

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
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
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
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
      if (!mounted) return;
      setState(() {
        _books = list;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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
      if (!mounted) return;
      setState(() {
        _refPapers = results[0];
        _aiPapers = validAi;
        _isLoadingPapers = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoadingPapers = false);
    }
  }

  Future<void> _downloadAndViewPdf(String urlPath, String title) async {
    // Show a loading dialog while downloading
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
          // : 'https://100.60.191.242.sslip.io$urlPath';

      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'ngrok-skip-browser-warning': 'true',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (response.statusCode == 200 || response.statusCode == 201) {
        final bytes = response.bodyBytes;
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SavedPdfViewerScreen(
              pdfBytes: bytes,
              title: title,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            backgroundColor: AuthTheme.error,
            content: Text(
              'Failed to load PDF: ${response.statusCode}',
              style: const TextStyle(fontFamily: AuthTheme.fontFamily),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: AuthTheme.error,
          content: Text(
            'Error downloading PDF: $e',
            style: const TextStyle(fontFamily: AuthTheme.fontFamily),
          ),
        ),
      );
    }
  }

  void _showAddBookSheet() {
    BookFormSheet.show(
      context: context,
      title: 'Add Book',
      subtitle: 'Give your book a name to get started.',
      submitButtonText: 'Add Book',
      onSubmit: (name) async {
        await _bookService.createBook(widget.subject['id'], name);
        _fetchBooks();
      },
    );
  }

  void _showEditBookSheet(Map<String, dynamic> book) {
    BookFormSheet.show(
      context: context,
      title: 'Edit Book',
      subtitle: 'Update the name of your book.',
      submitButtonText: 'Save Changes',
      initialName: book['name'] ?? book['title'],
      onSubmit: (name) async {
        await _bookService.updateBook(book['id'], name);
        _fetchBooks();
      },
    );
  }

  void _showDeleteBookDialog(Map<String, dynamic> book) {
    BookDeleteDialog.show(
      context: context,
      bookName: (book['name'] ?? book['title'] ?? 'this book').toString(),
      onConfirmDelete: () async {
        await _bookService.deleteBook(book['id']);
        _fetchBooks();
      },
    );
  }

  void _openBookChapters(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookChaptersScreen(
          book: book,
          subject: widget.subject,
        ),
      ),
    ).then((_) => _fetchBooks());
  }

  void _openPaperWizard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaperWizardScreen(subject: widget.subject),
      ),
    ).then((_) => _fetchPapers());
  }

  void _openPaper(Map<String, dynamic> paper, bool isAi) async {
    if (isAi) {
      final alreadySaved = paper['pdf_url'] != null &&
          paper['pdf_url'].toString().isNotEmpty;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(
            subject: widget.subject,
            paper: paper,
            isReadOnly: alreadySaved,
          ),
        ),
      ).then((_) => _fetchPapers());
    } else {
      final urlPath = paper['file_url'];
      if (urlPath != null) {
        await _downloadAndViewPdf(urlPath.toString(), paper['title'] ?? 'paper');
      }
    }
  }

  void _showDeletePaperDialog(Map<String, dynamic> paper, bool isAi) {
    PaperDeleteDialog.show(
      context: context,
      paperTitle: (paper['title'] ?? (isAi ? 'Generated Paper' : 'Reference Paper')).toString(),
      isAi: isAi,
      onConfirmDelete: () async {
        if (isAi) {
          await _paperService.deletePaper(paper['id']);
        } else {
          await _refService.deleteReferencePaper(paper['id']);
        }
        await _fetchPapers();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = widget.subject['name'] as String? ?? 'Subject';
    final totalPapers = _aiPapers.length + _refPapers.length;
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);
    final hPadding = isDesktop ? 36.0 : (isTablet ? 28.0 : 20.0);

    return Scaffold(
      backgroundColor: AuthTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1050),
            child: Padding(
              padding: EdgeInsets.only(
                left: hPadding,
                right: hPadding,
                top: 14.0,
              ),
              child: Column(
                children: [
                  // Contextual Subject Header
                  SubjectDetailHeader(
                    subjectName: subjectName,
                    bookCount: _books.length,
                    paperCount: totalPapers,
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 18),

                  // Segmented Tabs: Books & Papers
                  SubjectDetailTabs(
                    controller: _tabController,
                    bookCount: _books.length,
                    paperCount: totalPapers,
                  ),

                  const SizedBox(height: 16),

                  // Tab Views
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
        ),
      ),
    );
  }

  Widget _buildBooksTab() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 8.0),
        child: DetailLoadingState(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AuthTheme.errorLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AuthTheme.errorBorder),
                ),
                child: const Icon(Icons.error_outline_rounded, color: AuthTheme.error, size: 26),
              ),
              const SizedBox(height: 16),
              const Text(
                "Couldn't load your books",
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AuthTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 13,
                  color: AuthTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 160,
                child: AuthPrimaryButton(
                  text: 'Try Again',
                  height: 42,
                  onPressed: _fetchBooks,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      return DetailEmptyState(
        illustrationAsset: SubjectDetailAssets.emptyBooks,
        title: 'No books yet',
        subtitle: 'Add a book to start organizing your study material.',
        buttonText: 'Add Book',
        onAction: _showAddBookSheet,
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBooks,
      color: AuthTheme.primary,
      backgroundColor: Colors.white,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(top: 4, bottom: 28),
        itemCount: _books.length + 1,
        itemBuilder: (context, index) {
          if (index == _books.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: AddBookTile(onTap: _showAddBookSheet),
            );
          }

          final book = _books[index];
          return BookCard(
            book: book,
            index: index,
            onTap: () => _openBookChapters(book),
            onEdit: () => _showEditBookSheet(book),
            onDelete: () => _showDeleteBookDialog(book),
          );
        },
      ),
    );
  }

  Widget _buildPapersTab() {
    final List<Map<String, dynamic>> combinedList = [
      ..._aiPapers.map((p) => {...p, 'is_ai': true}),
      ..._refPapers.map((p) => {...p, 'is_ai': false}),
    ];

    return Column(
      children: [
        // Primary CTA: Create Paper with AI (only shown when papers exist)
        if (!_isLoadingPapers && combinedList.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 14.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                boxShadow: AuthTheme.buttonShadow,
              ),
              child: AuthPrimaryButton(
                text: 'Create Paper with AI',
                height: 48,
                icon: const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
                onPressed: _openPaperWizard,
              ),
            ),
          ),

        // Papers List / States
        Expanded(
          child: _isLoadingPapers
              ? const DetailLoadingState()
              : combinedList.isEmpty
                  ? DetailEmptyState(
                      illustrationAsset: SubjectDetailAssets.emptyPapers,
                      title: 'No papers yet',
                      subtitle: 'Create your first paper to get started.',
                      buttonText: 'Create Paper with AI',
                      buttonIcon: Icons.auto_awesome_rounded,
                      onAction: _openPaperWizard,
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchPapers,
                      color: AuthTheme.primary,
                      backgroundColor: Colors.white,
                      child: ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.only(top: 4, bottom: 28),
                        itemCount: combinedList.length,
                        itemBuilder: (context, index) {
                          final paper = combinedList[index];
                          final isAi = paper['is_ai'] == true;

                          return PaperCard(
                            paper: paper,
                            onTap: () => _openPaper(paper, isAi),
                            onDelete: () => _showDeletePaperDialog(paper, isAi),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}
