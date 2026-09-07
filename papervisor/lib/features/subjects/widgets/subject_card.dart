import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SubjectCard extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const SubjectCard({
    Key? key,
    required this.subject,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconColor = Color(subject['iconColor']);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(Icons.menu_book, color: iconColor, size: 18),
                ),
                if (onEdit != null || onDelete != null)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert, color: AppColors.textTertiary, size: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      onSelected: (val) {
                        if (val == 'edit') onEdit?.call();
                        if (val == 'delete') onDelete?.call();
                      },
                      itemBuilder: (ctx) => [
                        if (onEdit != null)
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18, color: AppColors.textPrimary),
                                SizedBox(width: 8),
                                Text('Edit Subject'),
                              ],
                            ),
                          ),
                        if (onDelete != null)
                          const PopupMenuItem(
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
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              subject['name'],
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text('${subject['bookCount']} books', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.0),
                  child: Text('•', style: TextStyle(color: AppColors.textTertiary, fontSize: 11)),
                ),
                Text('${subject['paperCount']} papers', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
