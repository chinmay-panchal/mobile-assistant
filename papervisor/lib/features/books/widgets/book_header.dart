import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Book Icon Badge
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBAE6FD)),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF0284C7),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Book & Subject Titles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          subjectName.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AuthTheme.textTertiary,
                            letterSpacing: 0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        ' · ',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AuthTheme.textTertiary,
                        ),
                      ),
                      Text(
                        '$chapterCount ${chapterCount == 1 ? "Chapter" : "Chapters"}',
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0284C7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    bookTitle.toUpperCase(),
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
