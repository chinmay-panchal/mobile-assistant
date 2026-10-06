import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_illustration.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../constants/subject_assets.dart';

/// Friendly empty state displayed when a workspace contains no subjects.
class SubjectEmptyState extends StatelessWidget {
  final VoidCallback onAddSubject;

  const SubjectEmptyState({super.key, required this.onAddSubject});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuthIllustration(
              assetPath: SubjectAssets.emptySubjects,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'No subjects yet',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AuthTheme.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your first subject to start organizing your books and papers.',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AuthTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 220,
              child: AuthPrimaryButton(
                text: 'Add Subject',
                onPressed: onAddSubject,
                icon: const Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
