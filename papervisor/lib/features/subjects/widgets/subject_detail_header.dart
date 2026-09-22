import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Contextual header for the Subject Detail screen.
/// Displays back button, subject icon badge, subject name, and live counts for Books & Papers.
class SubjectDetailHeader extends StatelessWidget {
  final String subjectName;
  final int bookCount;
  final int paperCount;
  final VoidCallback? onBack;

  const SubjectDetailHeader({
    super.key,
    required this.subjectName,
    required this.bookCount,
    required this.paperCount,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Subject Icon Container
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE), // Soft Sky Pastel
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBAE6FD)),
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
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AuthTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Text(
                    '$bookCount ${bookCount == 1 ? "Book" : "Books"} · $paperCount ${paperCount == 1 ? "Paper" : "Papers"}',
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AuthTheme.textSecondary,
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
