import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Modern, tactile book card featuring pastel color identity,
/// prominent book name, secondary indicator, and contextual action menu.
class BookCard extends StatelessWidget {
  final Map<String, dynamic> book;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    final title = (book['title'] ?? book['name'] ?? 'Untitled Book').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 14.0,
            ),
            child: Row(
              children: [
                // Clean Slate Book Icon Container
                Container(
                  width: 44,
                  height: 44,
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
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: Color(0xFF0284C7),
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // Book Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: TextStyle(
                          fontFamily: WorkspaceTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WorkspaceTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Chapters & study material',
                        style: TextStyle(
                          fontFamily: WorkspaceTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: WorkspaceTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Actions: Three-dot menu and Chevron
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: WorkspaceTheme.textSecondary.withValues(
                            alpha: 0.7,
                          ),
                        ),
                        splashRadius: 20,
                        color: WorkspaceTheme.surfaceWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: WorkspaceTheme.borderSubtle),
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
                                    'Edit Book',
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
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    size: 18,
                                    color: WorkspaceTheme.error,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Delete Book',
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
                    Icon(
                      Icons.chevron_right_rounded,
                      color: WorkspaceTheme.textTertiary,
                      size: 20,
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
