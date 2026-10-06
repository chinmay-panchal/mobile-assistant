import 'package:flutter/material.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Modern, tactile subject card featuring pastel color identity,
/// deterministic icon assignment, book counter, and contextual action menu.
class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  static const IconData subjectIcon = Icons.auto_stories_rounded;

  @override
  Widget build(BuildContext context) {
    final name = subject['name'] as String? ?? 'Untitled Subject';
    final bookCount = subject['bookCount'] as int? ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        border: Border.all(color: WorkspaceTheme.borderSubtle, width: 1.2),
        boxShadow: WorkspaceTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Icon Container and Three-dot Menu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Unified Common Icon Badge with Clean SaaS Styling
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WorkspaceTheme.isDark
                            ? const Color(0xFF151F32)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: WorkspaceTheme.isDark
                              ? const Color(0xFF1E40AF)
                              : const Color(0xFFBAE6FD),
                        ),
                      ),
                      child: Icon(
                        subjectIcon,
                        color: WorkspaceTheme.isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0284C7),
                        size: 20,
                      ),
                    ),

                    // Contextual Action Menu Button
                    if (onEdit != null || onDelete != null)
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          color: WorkspaceTheme.surfaceWhite,
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: WorkspaceTheme.textSecondary.withValues(
                              alpha: 0.7,
                            ),
                            size: 18,
                          ),
                          splashRadius: 16,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: WorkspaceTheme.borderSubtle,
                            ),
                          ),
                          elevation: 4,
                          shadowColor: Colors.black.withValues(alpha: 0.08),
                          onSelected: (value) {
                            if (value == 'edit') onEdit?.call();
                            if (value == 'delete') onDelete?.call();
                          },
                          itemBuilder: (context) => [
                            if (onEdit != null)
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: WorkspaceTheme.textPrimary,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Edit Subject',
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: WorkspaceTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (onDelete != null)
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: WorkspaceTheme.error,
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Delete Subject',
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: WorkspaceTheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Bottom Content: Subject Name and Book Count
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: WorkspaceTheme.textPrimary,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 12,
                          color: WorkspaceTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$bookCount ${bookCount == 1 ? "book" : "books"}',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: WorkspaceTheme.textSecondary,
                          ),
                        ),
                      ],
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
}
