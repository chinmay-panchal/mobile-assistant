import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Distinct outlined tile in the Subject grid for triggering the Add Subject action.
class AddSubjectTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddSubjectTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              borderRadius: AuthTheme.radiusCard,
              color: AuthTheme.inputBorder,
              strokeWidth: 1.5,
              dashLength: 6,
              dashGap: 4,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular / Rounded Icon Badge with Plus
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Action Title
                  const Text(
                    'Add Subject',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  // Supporting Text
                  const Text(
                    'Create a new subject',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AuthTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double borderRadius;
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  _DashedBorderPainter({
    required this.borderRadius,
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.dashGap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.borderRadius != borderRadius ||
      oldDelegate.dashLength != dashLength ||
      oldDelegate.dashGap != dashGap;
}
