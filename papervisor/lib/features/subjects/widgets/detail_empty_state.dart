import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_illustration.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Reusable friendly empty state for Books and Papers lists.
class DetailEmptyState extends StatelessWidget {
  final String illustrationAsset;
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData buttonIcon;
  final VoidCallback onAction;

  const DetailEmptyState({
    super.key,
    required this.illustrationAsset,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    this.buttonIcon = Icons.add_rounded,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthIllustration(assetPath: illustrationAsset, height: 140),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AuthTheme.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AuthTheme.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: 220,
              child: AuthPrimaryButton(
                text: buttonText,
                height: 44,
                icon: Icon(buttonIcon, size: 18, color: Colors.white),
                onPressed: onAction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
