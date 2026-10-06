import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Clean dashed-border action tile to trigger the Add Book action.
class AddBookTile extends StatelessWidget {
  final VoidCallback onTap;

  const AddBookTile({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        child: Container(
          decoration: BoxDecoration(
            color: WorkspaceTheme.surfaceMuted,
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
          ),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              borderRadius: WorkspaceTheme.radiusCard,
              color: WorkspaceTheme.borderSubtle,
              strokeWidth: 1.5,
              dashLength: 6,
              dashGap: 4,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 18.0,
                horizontal: 20.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_rounded,
                    color: WorkspaceTheme.isDark
                        ? const Color(0xFF38BDF8)
                        : WorkspaceTheme.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add Book',
                    style: TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: WorkspaceTheme.isDark
                          ? const Color(0xFF38BDF8)
                          : WorkspaceTheme.primaryDark,
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
