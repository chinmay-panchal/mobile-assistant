import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Clean dashed-border action box to trigger the Add Chapter flow.
class AddChapterTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddChapterTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              borderRadius: 20,
              color: const Color(0xFFCBD5E1),
              strokeWidth: 1.5,
              dashLength: 6,
              dashGap: 4,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFBAE6FD)),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF0284C7),
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add Chapter',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Create a new chapter for this book',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AuthTheme.textSecondary,
                    ),
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
