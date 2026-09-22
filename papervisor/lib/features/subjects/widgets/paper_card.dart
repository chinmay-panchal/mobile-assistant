import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

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
    final isAi = paper['is_ai'] == true;
    final title = (paper['title'] ?? (isAi ? 'Generated Paper' : 'Reference Paper')).toString();
    final marks = paper['total_marks'] as int? ?? 0;

    final Color accentColor = isAi ? AuthTheme.accentSky : AuthTheme.accentCobalt;
    final Color iconBg = const Color(0xFFEFF6FF);
    final IconData icon = isAi ? Icons.auto_awesome_rounded : Icons.description_rounded;

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
                // Soft Pastel Document Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 14),

                // Paper Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
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
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isAi) ...[
                                  Icon(Icons.auto_awesome, size: 10, color: accentColor),
                                  const SizedBox(width: 3),
                                ],
                                Text(
                                  isAi ? 'AI Paper' : 'Reference',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
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
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$marks Marks',
                                style: const TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AuthTheme.textSecondary,
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
                    color: AuthTheme.error,
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
                  color: AuthTheme.textTertiary,
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
