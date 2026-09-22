import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Clean dashed-border action tile to trigger the Add Book action.
class AddBookTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddBookTile({
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
              color: const Color(0xFFC7D2FE),
              strokeWidth: 1.5,
              dashLength: 6,
              dashGap: 4,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 18.0, horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AuthTheme.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Add Book',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.primary,
                      letterSpacing: -0.2,
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
