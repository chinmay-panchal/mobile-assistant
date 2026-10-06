import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Modern segmented pill tab bar for switching between Books and Papers.
class SubjectDetailTabs extends StatelessWidget {
  final TabController controller;
  final int bookCount;
  final int paperCount;
  final bool isLoadingBooks;
  final bool isLoadingPapers;

  const SubjectDetailTabs({
    super.key,
    required this.controller,
    required this.bookCount,
    required this.paperCount,
    this.isLoadingBooks = false,
    this.isLoadingPapers = false,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: WorkspaceTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: WorkspaceTheme.isDark ? 0.3 : 0.06,
              ),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: WorkspaceTheme.textPrimary,
        unselectedLabelColor: WorkspaceTheme.textSecondary,
        labelStyle: TextStyle(
          fontFamily: WorkspaceTheme.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: WorkspaceTheme.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_stories_rounded, size: 16),
                const SizedBox(width: 8),
                const Text('Books'),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.canvas,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isLoadingBooks
                      ? SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: WorkspaceTheme.isDark
                                ? const Color(0xFF38BDF8)
                                : WorkspaceTheme.accentCobalt,
                          ),
                        )
                      : Text(
                          '$bookCount',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: WorkspaceTheme.textPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.description_rounded, size: 16),
                const SizedBox(width: 8),
                const Text('Papers'),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.canvas,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: isLoadingPapers
                      ? SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: WorkspaceTheme.isDark
                                ? const Color(0xFF38BDF8)
                                : WorkspaceTheme.accentCobalt,
                          ),
                        )
                      : Text(
                          '$paperCount',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: WorkspaceTheme.textPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
