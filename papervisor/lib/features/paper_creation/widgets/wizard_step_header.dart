import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Clean, unified header for all 5 steps of the Paper Creation Wizard.
/// Displays subject identity breadcrumb, step counter badge (e.g. "Step 1 of 5"),
/// step title & subtitle, and an animated 5-segment progress bar.
///
/// Designed per Papervisor design system without a top-left back button.
class WizardStepHeader extends StatelessWidget {
  final String subjectName;
  final int currentStep; // 1-indexed (1 to 5)
  final String title;
  final String subtitle;
  final Widget? trailing;

  const WizardStepHeader({
    super.key,
    required this.subjectName,
    required this.currentStep,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Row: Subject Badge + Step Counter Pill + Optional Trailing
            Row(
              children: [
                // Subject Icon Badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    size: 16,
                    color: Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 10),

                // Subject Name Breadcrumb
                Flexible(
                  child: Text(
                    subjectName,
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AuthTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),

                // Step Counter Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Text(
                    'Step $currentStep of 5',
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0284C7),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                if (trailing != null) ...[
                  const Spacer(),
                  trailing!,
                ],
              ],
            ),

            const SizedBox(height: 12),

            // Step Title & Subtitle
            Text(
              title,
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AuthTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AuthTheme.textSecondary,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 14),

            // 5-Segment Progress Bar
            Row(
              children: List.generate(5, (index) {
                final isCompleted = index < currentStep;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                    height: 5,
                    decoration: BoxDecoration(
                      color: isCompleted ? AuthTheme.primary : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
