import 'package:flutter/material.dart';
import '../constants/workspace_theme.dart';

/// Modern, tactile workspace card featuring clean SaaS surface identity,
/// subject counters, contextual action menu, and smooth tap feedback.
class WorkspaceCard extends StatefulWidget {
  final Map<String, dynamic> workspace;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int index;
  final EdgeInsetsGeometry? margin;

  const WorkspaceCard({
    super.key,
    required this.workspace,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.index = 0,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<WorkspaceCard> createState() => _WorkspaceCardState();
}

class _WorkspaceCardState extends State<WorkspaceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final name = (widget.workspace['name'] as String? ?? 'Untitled Workspace').toUpperCase();
    final subjectCount = widget.workspace['subjectCount'] as int? ?? 0;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        border: Border.all(
          color: _isHovered ? WorkspaceTheme.accentCobalt.withValues(alpha: 0.6) : WorkspaceTheme.borderSubtle,
          width: 1.2,
        ),
        boxShadow: _isHovered ? WorkspaceTheme.cardHoverShadow : WorkspaceTheme.cardShadow,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Folder Icon Badge + Context Menu
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isHovered ? WorkspaceTheme.accentCobalt : WorkspaceTheme.accentLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _isHovered ? WorkspaceTheme.accentCobalt : WorkspaceTheme.accentBorder,
                          ),
                        ),
                        child: Icon(
                          Icons.folder_rounded,
                          color: _isHovered ? Colors.white : WorkspaceTheme.accentSky,
                          size: 20,
                        ),
                      ),
                      if (widget.onEdit != null || widget.onDelete != null)
                        PopupMenuButton<String>(
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: WorkspaceTheme.textMuted,
                            size: 19,
                          ),
                          splashRadius: 18,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: const BorderSide(color: WorkspaceTheme.borderSubtle),
                          ),
                          elevation: 4,
                          shadowColor: WorkspaceTheme.primaryDark.withValues(alpha: 0.08),
                          onSelected: (value) {
                            if (value == 'edit') widget.onEdit?.call();
                            if (value == 'delete') widget.onDelete?.call();
                          },
                          itemBuilder: (context) => [
                            if (widget.onEdit != null)
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 17, color: WorkspaceTheme.textPrimary),
                                    SizedBox(width: 10),
                                    Text(
                                      'Edit Workspace',
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                        color: WorkspaceTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (widget.onDelete != null)
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded, size: 17, color: WorkspaceTheme.error),
                                    SizedBox(width: 10),
                                    Text(
                                      'Delete Workspace',
                                      style: TextStyle(
                                        fontFamily: WorkspaceTheme.fontFamily,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: WorkspaceTheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),

                  // Middle: Workspace Name
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: WorkspaceTheme.fontFamily,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                      color: WorkspaceTheme.textPrimary,
                      letterSpacing: -0.3,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Bottom Row: Subject Count Pill + Forward Arrow
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8.5, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: WorkspaceTheme.surfaceMuted,
                          borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
                          border: Border.all(color: WorkspaceTheme.borderSubtle),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.layers_outlined,
                              size: 13,
                              color: WorkspaceTheme.accentSky,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$subjectCount ${subjectCount == 1 ? "Subject" : "Subjects"}',
                              style: const TextStyle(
                                fontFamily: WorkspaceTheme.fontFamily,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: WorkspaceTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: _isHovered ? WorkspaceTheme.primaryDark : WorkspaceTheme.surfaceSubtle,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isHovered ? WorkspaceTheme.primaryDark : WorkspaceTheme.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: _isHovered ? Colors.white : WorkspaceTheme.textTertiary,
                          size: 14,
                        ),
                      ),
                    ],
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

/// Action card displayed as the final item in the workspace grid
/// with a dashed border, plus icon, and "New workspace" label.
class NewWorkspaceCard extends StatefulWidget {
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;

  const NewWorkspaceCard({
    super.key,
    required this.onTap,
    this.margin = EdgeInsets.zero,
  });

  @override
  State<NewWorkspaceCard> createState() => _NewWorkspaceCardState();
}

class _NewWorkspaceCardState extends State<NewWorkspaceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isHovered
        ? WorkspaceTheme.accentCobalt.withValues(alpha: 0.8)
        : WorkspaceTheme.borderMedium;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: _isHovered
            ? WorkspaceTheme.accentLight.withValues(alpha: 0.45)
            : WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        boxShadow: _isHovered ? WorkspaceTheme.cardHoverShadow : null,
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
            onTap: widget.onTap,
            child: CustomPaint(
              painter: _DashedBorderPainter(
                borderRadius: WorkspaceTheme.radiusCard,
                color: borderColor,
                strokeWidth: 1.5,
                dashLength: 6,
                dashGap: 4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _isHovered ? WorkspaceTheme.accentCobalt : WorkspaceTheme.accentLight,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isHovered ? WorkspaceTheme.accentCobalt : WorkspaceTheme.accentBorder,
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: _isHovered ? Colors.white : WorkspaceTheme.accentCobalt,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create Workspace',
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: _isHovered ? WorkspaceTheme.accentCobalt : WorkspaceTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add subjects, books & papers',
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w400,
                        color: WorkspaceTheme.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
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
    this.strokeWidth = 1.2,
    this.dashLength = 6.0,
    this.dashGap = 4.0,
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

