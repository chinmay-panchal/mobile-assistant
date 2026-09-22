import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Minimal, clean top header for the Explore PYQs experience.
/// Per requirements, does NOT render any visible back arrow button.
class ExploreHeader extends StatelessWidget {
  final int downloadCount;
  final VoidCallback onHistoryTap;

  const ExploreHeader({
    super.key,
    required this.downloadCount,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AuthTheme.inputBorder, width: 1),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // AI Sparkle Badge + Title
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBAE6FD), width: 1),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: Color(0xFF0284C7),
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PYQ Explorer',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AuthTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'Find previous year questions',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AuthTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Download History Button
            Tooltip(
              message: 'Download history',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AuthTheme.radiusSmall),
                      onTap: onHistoryTap,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(AuthTheme.radiusSmall),
                          border: Border.all(color: AuthTheme.inputBorder),
                        ),
                        child: const Icon(
                          Icons.history_rounded,
                          size: 22,
                          color: AuthTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  if (downloadCount > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: AuthTheme.cardShadow,
                        ),
                        child: Center(
                          child: Text(
                            downloadCount > 99 ? '99+' : '$downloadCount',
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
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
