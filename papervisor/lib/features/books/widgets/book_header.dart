import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/utils/responsive.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Top header for the Book Chapters screen displaying book context,
/// subject breadcrumb, chapter counter badge, and back button.
class BookHeader extends StatelessWidget {
  final String bookTitle;
  final String subjectName;
  final int chapterCount;
  final VoidCallback? onBack;
  final VoidCallback? onPreviewBook;

  const BookHeader({
    super.key,
    required this.bookTitle,
    required this.subjectName,
    required this.chapterCount,
    this.onBack,
    this.onPreviewBook,
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
            message: 'Back to Books',
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

        // Book Icon Badge
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
            Icons.menu_book_rounded,
            color: Color(0xFF0284C7),
            size: 22,
          ),
        ),
        const SizedBox(width: 12),

        // Book & Subject Titles
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bookTitle.toUpperCase(),
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
                  Flexible(
                    child: Text(
                      subjectName.toUpperCase(),
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WorkspaceTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: WorkspaceTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '$chapterCount ${chapterCount == 1 ? "Chapter" : "Chapters"}',
                    style: const TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Optional Quick PDF Preview Action
        if (onPreviewBook != null) ...[
          const SizedBox(width: 8),
          Tooltip(
            message: 'Preview Book PDF',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPreviewBook,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: WorkspaceTheme.isDark
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFFBFDBFE),
                    ),
                  ),
                  child: const Icon(
                    Icons.picture_as_pdf_rounded,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
