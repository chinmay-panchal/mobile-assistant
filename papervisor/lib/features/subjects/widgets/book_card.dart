import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

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
    final title = (book['title'] ?? book['name'] ?? 'Untitled Book').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AuthTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
        border: Border.all(color: AuthTheme.inputBorder, width: 1.2),
        boxShadow: AuthTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Clean Slate Book Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
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
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Chapters & study material',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AuthTheme.textSecondary,
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
                        icon: Icon(Icons.more_vert_rounded, color: AuthTheme.textSecondary.withValues(alpha: 0.7)),
                        splashRadius: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AuthTheme.inputBorder),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withValues(alpha: 0.08),
                        onSelected: (value) {
                          if (value == 'edit') onEdit?.call();
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          if (onEdit != null)
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: AuthTheme.textPrimary),
                                  SizedBox(width: 10),
                                  Text(
                                    'Edit Book',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AuthTheme.textPrimary,
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
                                  Icon(Icons.delete_outline_rounded, size: 18, color: AuthTheme.error),
                                  SizedBox(width: 10),
                                  Text(
                                    'Delete Book',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AuthTheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AuthTheme.textTertiary,
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
