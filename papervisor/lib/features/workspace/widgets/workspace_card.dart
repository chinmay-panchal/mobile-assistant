import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class WorkspaceCard extends StatelessWidget {
  final Map<String, dynamic> workspace;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const WorkspaceCard({
    Key? key,
    required this.workspace,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor = Color(workspace['color']);
    final iconColor = Color(workspace['iconColor']);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              right: -20,
              top: -20,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white.withOpacity(0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workspace['name'],
                          style: TextStyle(
                            color: iconColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.menu_book, size: 16, color: iconColor.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${workspace['subjectCount']} Subjects',
                                style: TextStyle(color: iconColor.withOpacity(0.8), fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(Icons.insert_drive_file_outlined, size: 16, color: iconColor.withOpacity(0.8)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${workspace['paperCount']} Papers',
                                style: TextStyle(color: iconColor.withOpacity(0.8), fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null || onDelete != null)
                        PopupMenuButton<String>(
                          icon: Icon(Icons.more_vert, color: iconColor),
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
                                    Text('Edit Workspace'),
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
                      CircleAvatar(
                        backgroundColor: iconColor,
                        child: const Icon(Icons.chevron_right, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
