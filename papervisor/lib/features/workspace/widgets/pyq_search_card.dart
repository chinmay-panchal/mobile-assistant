import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/workspace_assets.dart';
import '../constants/workspace_theme.dart';

/// Interactive feature card providing an elegant, professional entry point
/// for searching and downloading Previous Year Questions (PYQs).
class PyqSearchCard extends StatefulWidget {
  final VoidCallback onTap;

  const PyqSearchCard({super.key, required this.onTap});

  @override
  State<PyqSearchCard> createState() => _PyqSearchCardState();
}

class _PyqSearchCardState extends State<PyqSearchCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        decoration: BoxDecoration(
          color: WorkspaceTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
          border: Border.all(color: WorkspaceTheme.borderSubtle, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: WorkspaceTheme.primaryDark.withValues(alpha: 0.04),
              offset: const Offset(0, 3),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Refined Feature Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: WorkspaceTheme.accentLight,
                            borderRadius: BorderRadius.circular(
                              WorkspaceTheme.radiusPill,
                            ),
                            border: Border.all(
                              color: WorkspaceTheme.accentBorder,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: WorkspaceTheme.accentCobalt,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'PYQ Explorer',
                                style: TextStyle(
                                  fontFamily: WorkspaceTheme.fontFamily,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: WorkspaceTheme.accentCobalt,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Find Previous Year Questions',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            color: WorkspaceTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Search and download PYQs for your subjects.',
                          style: TextStyle(
                            fontFamily: WorkspaceTheme.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w400,
                            color: WorkspaceTheme.textSecondary,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          children: [
                            Text(
                              'Explore PYQs',
                              style: TextStyle(
                                fontFamily: WorkspaceTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: WorkspaceTheme.accentCobalt,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: WorkspaceTheme.accentCobalt,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Right SVG Graphic
                  Container(
                    width: 76,
                    height: 70,
                    padding: const EdgeInsets.all(4),
                    child: SvgPicture.asset(
                      WorkspaceAssets.pyqBanner,
                      fit: BoxFit.contain,
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
