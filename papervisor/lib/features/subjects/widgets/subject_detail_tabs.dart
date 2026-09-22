import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Modern segmented pill tab bar for switching between Books and Papers.
class SubjectDetailTabs extends StatelessWidget {
  final TabController controller;
  final int bookCount;
  final int paperCount;

  const SubjectDetailTabs({
    super.key,
    required this.controller,
    required this.bookCount,
    required this.paperCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9), // Soft Slate Tray
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TabBar(
        controller: controller,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        labelColor: AuthTheme.primary,
        unselectedLabelColor: AuthTheme.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: AuthTheme.fontFamily,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.1,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: AuthTheme.fontFamily,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$bookCount',
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$paperCount',
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
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
