import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Tactile card representing an AI-generated exam paper or reference paper.
class PaperCard extends StatelessWidget {
  final Map<String, dynamic> paper;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PaperCard({
    super.key,
    required this.paper,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    final isAi = paper['is_ai'] == true;
    final title =
        (paper['title'] ?? (isAi ? 'Generated Paper' : 'Reference Paper'))
            .toString();
    final marks = paper['total_marks'] as int? ?? 0;

    final Color accentColor = isAi
        ? WorkspaceTheme.accentSky
        : WorkspaceTheme.accentCobalt;
    final Color iconBg = WorkspaceTheme.isDark
        ? const Color(0xFF151F32)
        : const Color(0xFFEFF6FF);
    final IconData icon = isAi
        ? Icons.auto_awesome_rounded
        : Icons.description_rounded;

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
                // Soft Pastel Document Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: WorkspaceTheme.isDark
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFFBAE6FD),
                    ),
                  ),
                  child: Icon(icon, color: accentColor, size: 22),
                ),

                const SizedBox(width: 14),

                // Paper Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontFamily: WorkspaceTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: WorkspaceTheme.textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Type Badge (AI or Reference)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isAi) ...[
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 10,
                                    color: accentColor,
                                  ),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  isAi ? 'AI Paper' : 'Reference',
                                  style: TextStyle(
                                    fontFamily: WorkspaceTheme.fontFamily,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (isAi && marks > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: WorkspaceTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$marks Marks',
                                style: TextStyle(
                                  fontFamily: WorkspaceTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: WorkspaceTheme.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                // Delete Button & Chevron
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: WorkspaceTheme.error,
                    size: 20,
                  ),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                  onPressed: onDelete,
                  tooltip: 'Delete Paper',
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  color: WorkspaceTheme.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
