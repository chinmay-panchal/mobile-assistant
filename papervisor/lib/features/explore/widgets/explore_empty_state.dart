import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../auth/theme/auth_theme.dart';
import '../constants/explore_assets.dart';

/// Centered, clean empty state for Explore PYQs with search suggestions.
class ExploreEmptyState extends StatelessWidget {
  final ValueChanged<String> onSuggestionSelected;

  const ExploreEmptyState({super.key, required this.onSuggestionSelected});

  static const List<String> _suggestions = [
    'Find Physics PYQs',
    'Find DBMS previous year papers',
    'Find Mathematics PYQs',
    'Operating Systems 2024',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            SvgPicture.asset(
              ExploreAssets.exploreEmpty,
              width: 180,
              height: 130,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // Title
            const Text(
              'Find any PYQ',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AuthTheme.textPrimary,
                letterSpacing: -0.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Search previous year questions from your subjects, exams and topics.',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AuthTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Suggestions Label
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 15,
                  color: const Color(0xFF0284C7),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Popular searches',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AuthTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Suggestion Chips
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((suggestion) {
                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                    onTap: () => onSuggestionSelected(suggestion),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          AuthTheme.radiusPill,
                        ),
                        border: Border.all(color: const Color(0xFFBAE6FD)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_rounded,
                            size: 14,
                            color: Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            suggestion,
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AuthTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
