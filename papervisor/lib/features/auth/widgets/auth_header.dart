import 'package:flutter/material.dart';
import '../theme/auth_theme.dart';

/// Clean, modern header widget displaying title, optional badge, and supportive description.
class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? badgeText;
  final IconData? badgeIcon;
  final CrossAxisAlignment alignment;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeText,
    this.badgeIcon,
    this.alignment = CrossAxisAlignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        if (badgeText != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AuthTheme.pastelPurple,
              borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
              border: Border.all(color: AuthTheme.primary.withValues(alpha: 0.12)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (badgeIcon != null) ...[
                  Icon(badgeIcon, size: 14, color: AuthTheme.primary),
                  const SizedBox(width: 6),
                ],
                Text(
                  badgeText!,
                  style: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Text(
          title,
          style: AuthTheme.headingLarge,
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: AuthTheme.subtitle,
          textAlign: alignment == CrossAxisAlignment.center ? TextAlign.center : TextAlign.start,
        ),
      ],
    );
  }
}
