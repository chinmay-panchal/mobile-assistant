import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Contextual header for the Subject Detail screen.
/// Displays back button, subject icon badge, subject name, and live counts for Books & Papers.
class SubjectDetailHeader extends StatelessWidget {
  final String subjectName;
  final int bookCount;
  final int paperCount;
  final bool isLoadingBooks;
  final bool isLoadingPapers;
  final VoidCallback? onBack;

  const SubjectDetailHeader({
    super.key,
    required this.subjectName,
    required this.bookCount,
    required this.paperCount,
    this.isLoadingBooks = false,
    this.isLoadingPapers = false,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    final showWebBack = kIsWeb && !Responsive.isMobile(context);

    return Row(
      children: [
        // Optional Back Navigation Button (Shown on Web Desktop/Tablet only, hidden on phones)
        if (onBack != null && showWebBack) ...[
          Tooltip(
            message: 'Back to Subjects',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: WorkspaceTheme.borderSubtle),
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 20,
                    color: WorkspaceTheme.textPrimary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],

        // Subject Icon Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: WorkspaceTheme.isDark
                ? const Color(0xFF151F32)
                : const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: WorkspaceTheme.isDark
                  ? const Color(0xFF1E40AF)
                  : const Color(0xFFBAE6FD),
            ),
          ),
          child: const Icon(
            Icons.auto_stories_rounded,
            size: 22,
            color: Color(0xFF0284C7),
          ),
        ),

        const SizedBox(width: 12),

        // Subject Name & Counters Metadata
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                subjectName.toUpperCase(),
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: WorkspaceTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  if (isLoadingBooks || isLoadingPapers) ...[
                    SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: WorkspaceTheme.isDark
                            ? const Color(0xFF38BDF8)
                            : WorkspaceTheme.accentCobalt,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Loading library...',
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: WorkspaceTheme.textSecondary,
                      ),
                    ),
                  ] else
                    Text(
                      '$bookCount ${bookCount == 1 ? "Book" : "Books"} · $paperCount ${paperCount == 1 ? "Paper" : "Papers"}',
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WorkspaceTheme.textSecondary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
