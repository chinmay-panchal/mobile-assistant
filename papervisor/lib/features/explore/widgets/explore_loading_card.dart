import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Clean floating status card shown while searching across sources for a PYQ PDF.
class ExploreLoadingCard extends StatelessWidget {
  final AnimationController pulseCtrl;

  const ExploreLoadingCard({super.key, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      top: 14,
      child: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AuthTheme.radiusField),
              border: Border.all(
                color: AuthTheme.primary.withValues(
                  alpha: 0.25 + 0.35 * pulseCtrl.value,
                ),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AuthTheme.primary.withValues(
                    alpha: 0.08 + 0.08 * pulseCtrl.value,
                  ),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: child,
          );
        },
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AuthTheme.primary),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Searching for your PYQ PDF…',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Evaluating candidates and extracting documents',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AuthTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
