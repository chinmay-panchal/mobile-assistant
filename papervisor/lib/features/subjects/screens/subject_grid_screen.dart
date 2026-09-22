import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../../../../services/book_service.dart';
import '../../../../services/subject_service.dart';
import '../widgets/add_subject_tile.dart';
import '../widgets/subject_card.dart';
import '../widgets/subject_delete_dialog.dart';
import '../widgets/subject_empty_state.dart';
import '../widgets/subject_form_sheet.dart';
import '../widgets/subject_header.dart';
import '../widgets/subject_loading_state.dart';
import 'subject_detail_screen.dart';

/// Redesigned SubjectGridScreen matching the Papervisor modern pastel design system.
/// Displays subjects within a workspace in a 2-column responsive grid with an embedded
/// Add Subject tile, deterministic pastel visual identities, and contextual actions.
class SubjectGridScreen extends StatefulWidget {
  final Map<String, dynamic> workspace;

  const SubjectGridScreen({
    super.key,
    required this.workspace,
  });

  @override
  State<SubjectGridScreen> createState() => _SubjectGridScreenState();
}

class _SubjectGridScreenState extends State<SubjectGridScreen> {
  final SubjectService _subjectService = SubjectService();
  List<Map<String, dynamic>> _subjects = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  Future<void> _fetchSubjects() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final list = await _subjectService.getSubjects(widget.workspace['id']);

      // Fetch book counts in parallel for all subjects (preserving existing contract)
      final bookService = BookService();
      final bookCounts = await Future.wait(
        list.map((s) async {
          try {
            final books = await bookService.getBooks(s['id']);
            return books.length;
          } catch (_) {
            return 0;
          }
        }),
      );

      final enriched = list.asMap().entries.map((entry) {
        return {
          ...entry.value,
          'bookCount': bookCounts[entry.key],
          'paperCount': 0, // no papers endpoint yet
        };
      }).toList();

      if (!mounted) return;
      setState(() {
        _subjects = enriched;
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

  void _showAddSubjectSheet() {
    SubjectFormSheet.show(
      context: context,
      title: 'Add Subject',
      subtitle: 'Give your subject a name to get started.',
      submitButtonText: 'Add',
      onSubmit: (name) async {
        await _subjectService.createSubject(
          widget.workspace['id'],
          name,
          name.toUpperCase(),
        );
        _fetchSubjects();
      },
    );
  }

  void _showEditSubjectSheet(Map<String, dynamic> subject) {
    SubjectFormSheet.show(
      context: context,
      title: 'Edit Subject',
      subtitle: 'Update the name of your subject.',
      submitButtonText: 'Save Changes',
      initialName: subject['name'],
      onSubmit: (name) async {
        await _subjectService.updateSubject(subject['id'], name);
        _fetchSubjects();
      },
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> subject) {
    SubjectDeleteDialog.show(
      context: context,
      subjectName: subject['name'] ?? '',
      onConfirmDelete: () async {
        await _subjectService.deleteSubject(subject['id']);
        _fetchSubjects();
      },
    );
  }

  void _openSubjectDetail(Map<String, dynamic> subject) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectDetailScreen(
          subject: subject,
          workspace: widget.workspace,
        ),
      ),
    ).then((_) => _fetchSubjects());
  }

  @override
  Widget build(BuildContext context) {
    final workspaceName = widget.workspace['name'] as String? ?? 'Workspace';

    return Scaffold(
      backgroundColor: AuthTheme.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchSubjects,
          color: AuthTheme.primary,
          backgroundColor: Colors.white,
          child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // Workspace Header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        top: 14.0,
                        bottom: 20.0,
                      ),
                      child: SubjectHeader(
                        workspaceName: workspaceName,
                        subjectCount: _subjects.length,
                        onBack: () => Navigator.pop(context),
                      ),
                    ),
                  ),

                  // State Display: Loading, Error, Empty, or Responsive Grid
                  if (_isLoading)
                    const SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: SliverToBoxAdapter(
                        child: SubjectLoadingState(),
                      ),
                    )
                  else if (_error != null)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildErrorState(),
                    )
                  else if (_subjects.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: SubjectEmptyState(
                        onAddSubject: _showAddSubjectSheet,
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        right: 20.0,
                        bottom: 32.0,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.05,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Last tile in the grid is always the Add Subject tile
                            if (index == _subjects.length) {
                              return AddSubjectTile(
                                onTap: _showAddSubjectSheet,
                              );
                            }

                            final subject = _subjects[index];
                            return SubjectCard(
                              subject: subject,
                              index: index,
                              onTap: () => _openSubjectDetail(subject),
                              onEdit: () => _showEditSubjectSheet(subject),
                              onDelete: () => _showDeleteConfirmDialog(subject),
                            );
                          },
                          childCount: _subjects.length + 1,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
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
              "Couldn't load subjects",
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AuthTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Something went wrong while loading your subjects.',
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AuthTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 160,
              child: AuthPrimaryButton(
                text: 'Try Again',
                height: 42,
                onPressed: _fetchSubjects,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
