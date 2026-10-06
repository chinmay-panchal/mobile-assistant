import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../auth/theme/auth_theme.dart';
import '../constants/chapter_assets.dart';

/// Clean and friendly empty state displayed when a book has no chapters.
class ChapterEmptyState extends StatelessWidget {
  final VoidCallback? onAddChapter;

  const ChapterEmptyState({super.key, this.onAddChapter});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG Illustration
            SvgPicture.asset(
              ChapterAssets.emptyChapters,
              width: 220,
              height: 140,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),

            // Heading
            const Text(
              'No chapters yet',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AuthTheme.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Subtitle
            const Text(
              'Add your first chapter to organize this book and prepare exam papers.',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AuthTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
