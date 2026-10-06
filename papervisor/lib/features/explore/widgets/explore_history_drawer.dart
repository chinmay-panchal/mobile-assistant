import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../auth/theme/auth_theme.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../constants/explore_assets.dart';
import '../providers/explore_provider.dart';
import '../repositories/past_downloads_repository.dart';
import 'history_delete_dialog.dart';

/// Right-side drawer that acts as a polished document library for past downloaded PYQ PDFs.
class ExploreHistoryDrawer extends StatelessWidget {
  final ExploreProvider provider;
  final String Function(DateTime) formatDate;
  final Future<void> Function(DownloadedPdf) onOpenFile;

  const ExploreHistoryDrawer({
    super.key,
    required this.provider,
    required this.formatDate,
    required this.onOpenFile,
  });

  @override
  Widget build(BuildContext context) {
    final downloads = provider.downloads;
    final screenWidth = MediaQuery.of(context).size.width;
    final drawerWidth = min(screenWidth * 0.88, 380.0);

    return Drawer(
      width: drawerWidth,
      backgroundColor: WorkspaceTheme.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Top Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: WorkspaceTheme.isDark
                          ? const Color(0xFF151F32)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: WorkspaceTheme.borderSubtle),
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      color: WorkspaceTheme.isDark
                          ? const Color(0xFF38BDF8)
                          : WorkspaceTheme.primaryDark,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'History',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: WorkspaceTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          'Previously downloaded PYQs',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: WorkspaceTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: WorkspaceTheme.textSecondary,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(color: WorkspaceTheme.borderSubtle, height: 1),

            // Top Action Bar if items exist
            if (downloads.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Row(
                  children: [
                    Text(
                      '${downloads.length} ${downloads.length == 1 ? 'document' : 'documents'}',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WorkspaceTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: AuthTheme.errorLight,
                      borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AuthTheme.radiusPill,
                        ),
                        onTap: () {
                          HistoryDeleteDialog.showDeleteAll(
                            context: context,
                            onConfirm: () async {
                              await provider.removeAllDownloads();
                            },
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.delete_outline_rounded,
                                size: 14,
                                color: AuthTheme.error,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Delete All',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AuthTheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (downloads.isNotEmpty)
              Divider(color: WorkspaceTheme.borderSubtle, height: 1),

            // List of downloads or Empty state
            Expanded(
              child: downloads.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              ExploreAssets.historyEmpty,
                              width: 140,
                              height: 110,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No download history',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: WorkspaceTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Your downloaded PYQ PDFs will appear here for offline access.',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: WorkspaceTheme.textSecondary,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                      itemCount: downloads.length,
                      separatorBuilder: (context, _) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final pdf = downloads[index];
                        return _HistoryItemCard(
                          pdf: pdf,
                          dateStr: formatDate(pdf.downloadedAt),
                          onTap: () => onOpenFile(pdf),
                          onDelete: () {
                            HistoryDeleteDialog.showItemDelete(
                              context: context,
                              pdfTitle: pdf.title,
                              onConfirm: () async {
                                await provider.removeDownload(pdf);
                              },
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  final DownloadedPdf pdf;
  final String dateStr;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryItemCard({
    required this.pdf,
    required this.dateStr,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: WorkspaceTheme.surfaceWhite,
      borderRadius: BorderRadius.circular(AuthTheme.radiusField),
      child: InkWell(
        borderRadius: BorderRadius.circular(AuthTheme.radiusField),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AuthTheme.radiusField),
            border: Border.all(color: WorkspaceTheme.borderSubtle),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: WorkspaceTheme.isDark ? 0.2 : 0.02,
                ),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // PDF squircle
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: AuthTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Center(
                  child: Icon(
                    Icons.picture_as_pdf_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              // Title and date
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pdf.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: WorkspaceTheme.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 11,
                          color: WorkspaceTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          dateStr,
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: WorkspaceTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AuthTheme.error,
                  size: 18,
                ),
                tooltip: 'Delete',
                padding: const EdgeInsets.all(6),
                constraints: const BoxConstraints(),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
