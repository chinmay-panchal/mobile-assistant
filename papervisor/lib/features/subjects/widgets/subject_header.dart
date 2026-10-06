import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../workspace/constants/workspace_theme.dart';

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
    Provider.of<ThemeProvider?>(context, listen: true);
    final showWebBack = kIsWeb && !Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Navigation & Workspace Identity Bar
        Row(
          children: [
            // Optional Back Navigation Button (Shown on Web Desktop/Tablet only, hidden on phones)
            if (onBack != null && showWebBack) ...[
              Tooltip(
                message: 'Back to Workspaces',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: WorkspaceTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: WorkspaceTheme.borderSubtle),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: WorkspaceTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

            // Workspace Icon Badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: WorkspaceTheme.isDark
                    ? const Color(0xFF151F32)
                    : const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: WorkspaceTheme.isDark
                      ? const Color(0xFF1E40AF)
                      : const Color(0xFFBAE6FD),
                ),
              ),
              child: const Icon(
                Icons.folder_rounded,
                size: 18,
                color: Color(0xFF38BDF8),
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
                    style: TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: WorkspaceTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: WorkspaceTheme.isDark
                              ? const Color(0xFF151F32)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(
                            WorkspaceTheme.radiusPill,
                          ),
                          border: Border.all(
                            color: WorkspaceTheme.isDark
                                ? const Color(0xFF1E40AF)
                                : const Color(0xFFBAE6FD),
                          ),
                        ),
                        child: Text(
                          '$subjectCount ${subjectCount == 1 ? "Subject" : "Subjects"}',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: WorkspaceTheme.isDark
                                ? const Color(0xFF38BDF8)
                                : const Color(0xFF0284C7),
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
        Text(
          'Your Subjects',
          style: TextStyle(
            fontFamily: WorkspaceTheme.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: WorkspaceTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Organize your subjects and study material in one place.',
          style: TextStyle(
            fontFamily: WorkspaceTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: WorkspaceTheme.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
