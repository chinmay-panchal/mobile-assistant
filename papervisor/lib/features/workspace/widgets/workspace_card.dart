import 'package:flutter/material.dart';
import '../constants/workspace_theme.dart';

/// Modern, tactile workspace card featuring clean SaaS surface identity,
/// subject counters, contextual action menu, and smooth tap feedback.
class WorkspaceCard extends StatelessWidget {
  final Map<String, dynamic> workspace;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;

  const WorkspaceCard({
    super.key,
    required this.workspace,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    const icon = Icons.folder_outlined;
    final name = (workspace['name'] as String? ?? 'Untitled Workspace').toUpperCase();
    final subjectCount = workspace['subjectCount'] as int? ?? 0;

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
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              children: [
                // Clean Architectural Workspace Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.accentLight,
                    borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
                    border: Border.all(color: WorkspaceTheme.accentBorder),
                  ),
                  child: Icon(
                    icon,
                    color: WorkspaceTheme.accentSky,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // Workspace Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontFamily: WorkspaceTheme.fontFamily,
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: WorkspaceTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: WorkspaceTheme.accentLight,
                              borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
                              border: Border.all(color: WorkspaceTheme.accentBorder.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.layers_outlined,
                                  size: 12,
                                  color: WorkspaceTheme.accentSky,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$subjectCount ${subjectCount == 1 ? "Subject" : "Subjects"}',
                                  style: const TextStyle(
                                    fontFamily: WorkspaceTheme.fontFamily,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: WorkspaceTheme.accentSky,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: WorkspaceTheme.textMuted,
                          size: 20,
                        ),
                        splashRadius: 18,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: WorkspaceTheme.borderSubtle),
                        ),
                        elevation: 4,
                        shadowColor: WorkspaceTheme.primaryDark.withValues(alpha: 0.08),
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
                                  Icon(Icons.edit_outlined, size: 17, color: WorkspaceTheme.textPrimary),
                                  SizedBox(width: 10),
                                  Text(
                                    'Edit Workspace',
                                    style: TextStyle(
                                      fontFamily: WorkspaceTheme.fontFamily,
                                      fontSize: 13.5,
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
                                  Icon(Icons.delete_outline_rounded, size: 17, color: WorkspaceTheme.error),
                                  SizedBox(width: 10),
                                  Text(
                                    'Delete Workspace',
                                    style: TextStyle(
                                      fontFamily: WorkspaceTheme.fontFamily,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: WorkspaceTheme.error,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: WorkspaceTheme.surfaceSubtle,
                        shape: BoxShape.circle,
                        border: Border.all(color: WorkspaceTheme.borderSubtle),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: WorkspaceTheme.textTertiary,
                        size: 18,
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
  }
}

