import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

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
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                      ),
                      child: Icon(
                        subjectIcon,
                        color: const Color(0xFF0284C7),
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
                          icon: Icon(
                            Icons.more_vert_rounded,
                            color: AuthTheme.textSecondary.withValues(alpha: 0.7),
                            size: 18,
                          ),
                          splashRadius: 16,
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
                                      'Edit Subject',
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
                                      'Delete Subject',
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
                      style: const TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AuthTheme.textPrimary,
                        letterSpacing: -0.2,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_rounded,
                          size: 12,
                          color: AuthTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$bookCount ${bookCount == 1 ? "book" : "books"}',
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AuthTheme.textSecondary,
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
