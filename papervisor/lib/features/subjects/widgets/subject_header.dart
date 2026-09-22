import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Contextual workspace header displaying the workspace name, subject count badge,
/// back navigation button, and clean section title/subtitle.
class SubjectHeader extends StatelessWidget {
  final String workspaceName;
  final int subjectCount;
  final VoidCallback? onBack;

  const SubjectHeader({
    super.key,
    required this.workspaceName,
    required this.subjectCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Navigation & Workspace Identity Bar
        Row(
          children: [
            // Workspace Icon Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: const Icon(
                Icons.folder_rounded,
                size: 18,
                color: Color(0xFF0284C7),
              ),
            ),

            const SizedBox(width: 10),

            // Workspace Title & Subject Count Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workspaceName.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Text(
                          '$subjectCount ${subjectCount == 1 ? "Subject" : "Subjects"}',
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Section Title & Subtitle
        const Text(
          'Your Subjects',
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AuthTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Organize your subjects and study material in one place.',
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: AuthTheme.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
