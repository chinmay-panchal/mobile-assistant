import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/book_service.dart';
import '../../../services/subject_service.dart';
import '../../../services/workspace_service.dart';
import '../../auth/screens/login_screen.dart';
// import '../../explore/screens/explore_screen.dart';
import '../../paper_creation/screens/paper_wizard_screen.dart';
import '../../paper_creation/widgets/book_selection_sheet.dart';
import '../../subjects/screens/subject_grid_screen.dart';
import '../constants/workspace_theme.dart';
import '../widgets/profile_drawer.dart';
import '../widgets/workspace_card.dart';
import '../widgets/workspace_delete_dialog.dart';
import '../widgets/workspace_empty_state.dart';
import '../widgets/workspace_form_sheet.dart';
import '../widgets/workspace_loading_state.dart';
import '../widgets/workspace_primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
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
    _loadCachedWorkspaces();
    _fetchWorkspaces();
  }

  void _loadCachedWorkspaces() {
    final cached = _workspaceService.getCachedWorkspacesSync();
    final cachedBooks = _bookService.getCachedAllBooksSync();
    if (cached != null && cached.isNotEmpty) {
      _workspaces = cached;
      if (cachedBooks != null) _books = cachedBooks;
      _isLoading = false;
    }
  }

  Future<void> _fetchWorkspaces() async {
    // Only show loading indicator if we don't have any cached data to display
    if (_workspaces.isEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    } else {
      _error = null;
    }

    try {
      final results = await Future.wait([
        _workspaceService.getWorkspaces(),
        _bookService.getAllBooks().catchError((_) => <Map<String, dynamic>>[]),
      ]);
      final list = results[0];
      final allBooks = results[1];

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

  // void _openPyqSearch() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => const ExploreScreen(),
  //     ),
  //   );
  // }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: WorkspaceTheme.surfaceWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
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
                  child: const Icon(
                    Icons.logout_rounded,
                    color: WorkspaceTheme.error,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
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
                Text(
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

  Future<void> _handleDeleteProfile() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: WorkspaceTheme.surfaceWhite,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.errorLight,
                    shape: BoxShape.circle,
                    border: Border.all(color: WorkspaceTheme.errorBorder),
                  ),
                  child: const Icon(
                    Icons.delete_forever_rounded,
                    color: WorkspaceTheme.error,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete Educator Profile?',
                  style: TextStyle(
                    fontFamily: WorkspaceTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: WorkspaceTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This action is irreversible. All of your workspaces, subjects, syllabus books, and generated question papers will be permanently deleted.',
                  style: TextStyle(
                    fontFamily: WorkspaceTheme.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w400,
                    color: WorkspaceTheme.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
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
                        text: 'Delete',
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
      ),
    );

    if (confirmed == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: WorkspaceTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: WorkspaceTheme.borderSubtle),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Deleting profile & data...',
                    style: TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: WorkspaceTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      try {
        await _authService.deleteAccount();
      } catch (_) {}

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: Colors.green,
            content: const Text(
              'Your profile and all data have been permanently deleted.',
              style: TextStyle(
                fontFamily: WorkspaceTheme.fontFamily,
                color: Colors.white,
              ),
            ),
          ),
        );
      }
    }
  }

  void _showCreateWorkspaceSheet() {
    final existingNames = _workspaces
        .map((w) => (w['name'] as String?)?.trim())
        .whereType<String>()
        .toList();

    WorkspaceFormSheet.show(
      context: context,
      title: 'Create Workspace',
      subtitle: 'Create a class, course, or examination workspace.',
      submitButtonText: 'Create',
      existingNames: existingNames,
      onSubmit: (name) async {
        await _workspaceService.createWorkspace(name);
        _fetchWorkspaces();
      },
    );
  }

  void _showEditWorkspaceSheet(Map<String, dynamic> workspace) {
    final existingNames = _workspaces
        .map((w) => (w['name'] as String?)?.trim())
        .whereType<String>()
        .toList();

    WorkspaceFormSheet.show(
      context: context,
      title: 'Edit Workspace',
      subtitle: 'Update the name of this workspace.',
      submitButtonText: 'Save Changes',
      initialName: workspace['name'],
      existingNames: existingNames,
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
    Provider.of<ThemeProvider?>(context, listen: true);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 600;
    final hPadding = isMobile ? 16.0 : 24.0;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: ProfileDrawer(
        onLogout: _handleLogout,
        onDeleteProfile: _handleDeleteProfile,
      ),
      backgroundColor: WorkspaceTheme.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: RefreshIndicator(
              color: WorkspaceTheme.primaryDark,
              backgroundColor: WorkspaceTheme.surfaceWhite,
              onRefresh: _fetchWorkspaces,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(hPadding, 24.0, hPadding, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Navigation Header: Brand & Educator Identity + Quick Actions
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Brand mark
                              Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: WorkspaceTheme.primaryDark
                                              .withValues(alpha: 0.08),
                                          blurRadius: 6,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      'assets/workspace/illustrations/papervisor_logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Papervisor',
                                        style: TextStyle(
                                          fontFamily: WorkspaceTheme.fontFamily,
                                          fontSize: 15.5,
                                          fontWeight: FontWeight.w800,
                                          color: WorkspaceTheme.textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 1.5),
                                      Row(
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF10B981),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            'Educator Portal',
                                            style: TextStyle(
                                              fontFamily:
                                                  WorkspaceTheme.fontFamily,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                              color:
                                                  WorkspaceTheme.textTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              // Quick Action: "New Workspace" & Profile Drawer Button
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_workspaces.isNotEmpty) ...[
                                    Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: _showCreateWorkspaceSheet,
                                        borderRadius: BorderRadius.circular(
                                          WorkspaceTheme.radiusPill,
                                        ),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 8.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: WorkspaceTheme.primaryDark,
                                            borderRadius: BorderRadius.circular(
                                              WorkspaceTheme.radiusPill,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: WorkspaceTheme
                                                    .primaryDark
                                                    .withValues(alpha: 0.15),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.add_rounded,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 6),
                                              Text(
                                                'New Workspace',
                                                style: TextStyle(
                                                  fontFamily:
                                                      WorkspaceTheme.fontFamily,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                  letterSpacing: -0.1,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                  _buildProfileButton(),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // Unified Section Heading
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Your Workspaces',
                                style: TextStyle(
                                  fontFamily: WorkspaceTheme.fontFamily,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: WorkspaceTheme.textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              if (!_isLoading &&
                                  _error == null &&
                                  _workspaces.isNotEmpty) ...[
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.5,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: WorkspaceTheme.surfaceWhite,
                                    borderRadius: BorderRadius.circular(
                                      WorkspaceTheme.radiusPill,
                                    ),
                                    border: Border.all(
                                      color: WorkspaceTheme.borderSubtle,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: WorkspaceTheme.primaryDark
                                            .withValues(alpha: 0.03),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '${_workspaces.length} ${_workspaces.length == 1 ? "Workspace" : "Workspaces"}',
                                    style: TextStyle(
                                      fontFamily: WorkspaceTheme.fontFamily,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: WorkspaceTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Organize your subjects, syllabus books, and question papers in one place.',
                            style: TextStyle(
                              fontFamily: WorkspaceTheme.fontFamily,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w400,
                              color: WorkspaceTheme.textSecondary,
                              letterSpacing: -0.1,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Workspaces Grid / Empty State / Loading State / Error State
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      hPadding,
                      0,
                      hPadding,
                      96.0,
                    ), // Padding for FAB
                    sliver: _buildWorkspacesSliver(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Premium Pill Floating Action Button: "Generate Paper" with 24px margin
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
        child: _buildCreateFab(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildProfileButton() {
    return Tooltip(
      message: 'Educator Profile & Preferences',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
          onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
              border: Border.all(color: const Color(0xFF1E293B)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                    width: 1.2,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkspacesSliver() {
    if (_isLoading) {
      return const SliverToBoxAdapter(child: WorkspaceLoadingState());
    }

    if (_error != null) {
      return SliverToBoxAdapter(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: WorkspaceTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
                border: Border.all(
                  color: WorkspaceTheme.borderSubtle,
                  width: 1.2,
                ),
                boxShadow: WorkspaceTheme.cardShadow,
              ),
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
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      size: 24,
                      color: WorkspaceTheme.error,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
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
                    style: TextStyle(
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
                      icon: const Icon(
                        Icons.refresh_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_workspaces.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.only(top: 36.0, bottom: 24.0),
          child: WorkspaceEmptyState(
            onCreateWorkspace: _showCreateWorkspaceSheet,
          ),
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final int crossAxisCount = width < 640 ? 1 : (width < 960 ? 2 : 3);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 168,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index < _workspaces.length) {
          final workspace = _workspaces[index];
          return WorkspaceCard(
            workspace: workspace,
            index: index,
            margin: EdgeInsets.zero,
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
        } else {
          return NewWorkspaceCard(onTap: _showCreateWorkspaceSheet);
        }
      }, childCount: _workspaces.length + 1),
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
