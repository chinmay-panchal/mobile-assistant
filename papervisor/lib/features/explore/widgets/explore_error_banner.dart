import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Friendly error banner shown when search encounters an issue or cannot find a PDF.
class ExploreErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const ExploreErrorBanner({
    super.key,
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(AuthTheme.radiusField),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                color: Color(0xFF991B1B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onDismiss,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.close_rounded,
                  color: Color(0xFF991B1B),
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
