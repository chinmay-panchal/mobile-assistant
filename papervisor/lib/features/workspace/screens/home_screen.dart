import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../services/book_service.dart';
import '../../../services/subject_service.dart';
import '../../../services/workspace_service.dart';
import '../../auth/screens/login_screen.dart';
import '../../explore/screens/explore_screen.dart';
import '../../paper_creation/screens/paper_wizard_screen.dart';
import '../../paper_creation/widgets/book_selection_sheet.dart';
import '../../subjects/screens/subject_grid_screen.dart';
import '../constants/workspace_theme.dart';
import '../widgets/pyq_search_card.dart';
import '../widgets/workspace_card.dart';
import '../widgets/workspace_delete_dialog.dart';
import '../widgets/workspace_empty_state.dart';
import '../widgets/workspace_form_sheet.dart';
import '../widgets/workspace_header.dart';
import '../widgets/workspace_loading_state.dart';
import '../widgets/workspace_primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WorkspaceService _workspaceService = WorkspaceService();
  final AuthService _authService = AuthService();
  final BookService _bookService = BookService();

  List<Map<String, dynamic>> _workspaces = [];
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWorkspaces();
  }

  Future<void> _fetchWorkspaces() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _workspaceService.getWorkspaces(),
        _bookService.getAllBooks().catchError((_) => <Map<String, dynamic>>[]),
      ]);
      final list = results[0] as List<Map<String, dynamic>>;
      final allBooks = results[1] as List<Map<String, dynamic>>;

      // Fetch subject counts in parallel for all workspaces
      final subjectService = SubjectService();
      final subjectCounts = await Future.wait(
        list.map((ws) async {
          try {
            final subjects = await subjectService.getSubjects(ws['id']);
            return subjects.length;
          } catch (_) {
            return 0;
          }
        }),
      );

      final enriched = list.asMap().entries.map((entry) {
        return {
          ...entry.value,
          'subjectCount': subjectCounts[entry.key],
          'paperCount': 0,
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _workspaces = enriched;
        _books = allBooks;
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

  void _showSelectBookSheet() {
    if (_books.isEmpty) return;
    BookSelectionSheet.show(
      context: context,
      books: _books,
      onSelect: (book) {
        final subject = book['subject'] as Map<String, dynamic>?;
        if (subject != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaperWizardScreen(
                subject: subject,
                initialBookId: book['id']?.toString(),
              ),
            ),
          ).then((_) => _fetchWorkspaces());
        }
      },
    );
  }

  void _openPyqSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ExploreScreen(),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: WorkspaceTheme.surfaceWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.errorLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: WorkspaceTheme.errorBorder),
                ),
                child: const Icon(Icons.logout_rounded, color: WorkspaceTheme.error, size: 22),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign Out?',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WorkspaceTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to sign out of your account?',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: WorkspaceTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: WorkspacePrimaryButton(
                      text: 'Cancel',
                      isSecondary: true,
                      height: 44,
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WorkspacePrimaryButton(
                      text: 'Sign Out',
                      isDestructive: true,
                      height: 44,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showCreateWorkspaceSheet() {
    WorkspaceFormSheet.show(
      context: context,
      title: 'Create Workspace',
      subtitle: 'Create a class, course, or examination workspace.',
      submitButtonText: 'Create',
      onSubmit: (name) async {
        await _workspaceService.createWorkspace(name);
        _fetchWorkspaces();
      },
    );
  }

  void _showEditWorkspaceSheet(Map<String, dynamic> workspace) {
    WorkspaceFormSheet.show(
      context: context,
      title: 'Edit Workspace',
      subtitle: 'Update the name of this workspace.',
      submitButtonText: 'Save Changes',
      initialName: workspace['name'],
      onSubmit: (name) async {
        await _workspaceService.updateWorkspace(workspace['id'], name);
        _fetchWorkspaces();
      },
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> workspace) {
    WorkspaceDeleteDialog.show(
      context: context,
      workspaceName: workspace['name'] ?? '',
      onConfirmDelete: () async {
        await _workspaceService.deleteWorkspace(workspace['id']);
        _fetchWorkspaces();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkspaceTheme.canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: WorkspaceTheme.primaryDark,
          backgroundColor: WorkspaceTheme.surfaceWhite,
          onRefresh: _fetchWorkspaces,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header with greeting, PYQ and logout actions
                      WorkspaceHeader(
                        onSearchPyq: _openPyqSearch,
                        onLogout: _handleLogout,
                      ),
                      const SizedBox(height: 18),

                      // Visual PYQ Explorer Banner Entry Point
                      PyqSearchCard(onTap: _openPyqSearch),
                      const SizedBox(height: 24),

                      // Section Title: My Workspaces + Count Badge
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'My Workspaces',
                            style: TextStyle(
                              fontFamily: WorkspaceTheme.fontFamily,
                              fontSize: 17.5,
                              fontWeight: FontWeight.w700,
                              color: WorkspaceTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          if (!_isLoading && _error == null)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_books.isNotEmpty) ...[
                                  Tooltip(
                                    message: 'Create Workspace',
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _showCreateWorkspaceSheet,
                                        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          decoration: BoxDecoration(
                                            color: WorkspaceTheme.surfaceWhite,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: WorkspaceTheme.borderSubtle),
                                            boxShadow: [
                                              BoxShadow(
                                                color: WorkspaceTheme.primaryDark.withValues(alpha: 0.04),
                                                offset: const Offset(0, 1),
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.add_rounded,
                                            size: 16,
                                            color: WorkspaceTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                                  decoration: BoxDecoration(
                                    color: WorkspaceTheme.surfaceWhite,
                                    borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
                                    border: Border.all(color: WorkspaceTheme.borderSubtle),
                                    boxShadow: [
                                      BoxShadow(
                                        color: WorkspaceTheme.primaryDark.withValues(alpha: 0.03),
                                        offset: const Offset(0, 1),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${_workspaces.length} ${_workspaces.length == 1 ? "Workspace" : "Workspaces"}',
                                    style: const TextStyle(
                                      fontFamily: WorkspaceTheme.fontFamily,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: WorkspaceTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // Workspaces List / Empty State / Loading State / Error State
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 96.0), // Padding for FAB
                sliver: _buildWorkspacesSliver(),
              ),
            ],
          ),
        ),
      ),

      // Premium Pill Floating Action Button: "New Workspace"
      floatingActionButton: _buildCreateFab(),
    );
  }

  Widget _buildWorkspacesSliver() {
    if (_isLoading) {
      return const SliverToBoxAdapter(
        child: WorkspaceLoadingState(),
      );
    }

    if (_error != null) {
      return SliverToBoxAdapter(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: WorkspaceTheme.surfaceWhite,
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
            border: Border.all(color: WorkspaceTheme.borderSubtle, width: 1.2),
            boxShadow: WorkspaceTheme.cardShadow,
          ),
          child: Column(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.errorLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: WorkspaceTheme.errorBorder),
                ),
                child: const Icon(Icons.cloud_off_rounded, size: 24, color: WorkspaceTheme.error),
              ),
              const SizedBox(height: 14),
              const Text(
                "Couldn't load your workspaces",
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: WorkspaceTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _error!,
                style: const TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 13,
                  color: WorkspaceTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 140,
                child: WorkspacePrimaryButton(
                  text: 'Try Again',
                  height: 42,
                  onPressed: _fetchWorkspaces,
                  icon: const Icon(Icons.refresh_rounded, size: 17, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_workspaces.isEmpty) {
      return const SliverToBoxAdapter(
        child: WorkspaceEmptyState(),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final workspace = _workspaces[index];

          return WorkspaceCard(
            workspace: workspace,
            index: index,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SubjectGridScreen(workspace: workspace),
                ),
              ).then((_) => _fetchWorkspaces());
            },
            onEdit: () => _showEditWorkspaceSheet(workspace),
            onDelete: () => _showDeleteConfirmDialog(workspace),
          );
        },
        childCount: _workspaces.length,
      ),
    );
  }

  Widget _buildCreateFab() {
    final hasBooks = _books.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: WorkspaceTheme.primaryDark,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
        border: Border.all(color: WorkspaceTheme.primaryBorder),
        boxShadow: WorkspaceTheme.fabShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
          onTap: hasBooks ? _showSelectBookSheet : _showCreateWorkspaceSheet,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  hasBooks ? Icons.auto_awesome_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Text(
                  hasBooks ? 'Generate Paper' : 'New Workspace',
                  style: const TextStyle(
                    fontFamily: WorkspaceTheme.fontFamily,
                    fontSize: 14.5,
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
}
