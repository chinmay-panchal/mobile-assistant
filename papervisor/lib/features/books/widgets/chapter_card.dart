import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../auth/theme/auth_theme.dart';

/// Polished card presenting a chapter with number badge, title, page range,
/// optional PDF indicator / preview button, and contextual three-dot menu.
class ChapterCard extends StatelessWidget {
  final Map<String, dynamic> chapter;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onPreviewPdf;

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.onEdit,
    required this.onDelete,
    this.onPreviewPdf,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    final rawChapterNum = chapter['chapter_number'];
    final chapterNum = rawChapterNum != null ? rawChapterNum.toString() : '?';
    final formattedNum = chapterNum.length == 1 ? '0$chapterNum' : chapterNum;

    final chapterTitle =
        (chapter['name'] ?? chapter['title'] ?? 'Untitled Chapter').toString();
    final startPage = chapter['start_page'];
    final endPage = chapter['end_page'];
    final hasPageRange = startPage != null && endPage != null;
    final pageRangeText = hasPageRange
        ? 'Pages $startPage–$endPage'
        : 'Chapter $chapterNum';

    final hasPdf = chapter['file_url'] != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: WorkspaceTheme.isDark ? 0.3 : 0.025,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              // Chapter Number Badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.isDark
                      ? const Color(0xFF151F32)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: WorkspaceTheme.isDark
                        ? const Color(0xFF1E40AF)
                        : const Color(0xFFBAE6FD),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  formattedNum,
                  style: const TextStyle(
                    fontFamily: WorkspaceTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0284C7),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and Page Range
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chapterTitle,
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: WorkspaceTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.auto_stories_outlined,
                          size: 13,
                          color: WorkspaceTheme.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pageRangeText,
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: WorkspaceTheme.textSecondary,
                          ),
                        ),
                        if (hasPdf) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFA7F3D0),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.picture_as_pdf_rounded,
                                  size: 10,
                                  color: Color(0xFF059669),
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'PDF attached',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF059669),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Preview PDF Button if PDF exists
              if (hasPdf && onPreviewPdf != null) ...[
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPreviewPdf,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.visibility_outlined,
                            size: 13,
                            color: Color(0xFF2563EB),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Preview',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],

              // Contextual Three-dot Menu
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: WorkspaceTheme.textTertiary,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: WorkspaceTheme.borderSubtle),
                ),
                elevation: 4,
                surfaceTintColor: Colors.transparent,
                color: WorkspaceTheme.surfaceWhite,
                onSelected: (val) {
                  if (val == 'edit') {
                    onEdit();
                  } else if (val == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  PopupMenuItem(
                    value: 'edit',
                    height: 40,
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 17,
                          color: WorkspaceTheme.textPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Edit Chapter',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WorkspaceTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    height: 40,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          size: 17,
                          color: WorkspaceTheme.error,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Delete Chapter',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: WorkspaceTheme.error,
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
      ),
    );
  }
}
