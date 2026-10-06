import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/theme/auth_theme.dart';

/// Represents a single feature spotlight in the walkthrough.
class WalkthroughStep {
  final GlobalKey key;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Color iconBgColor;
  final String badgeText;
  final Widget? floatingWidget;
  final Widget? customContent;

  const WalkthroughStep({
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    this.accentColor = const Color(0xFF2563EB),
    this.iconBgColor = const Color(0xFFEFF6FF),
    required this.badgeText,
    this.floatingWidget,
    this.customContent,
  });
}

/// A production-ready, beautiful interactive feature walkthrough (coach mark spotlight).
/// Features:
/// - Smooth darkened scrim with an exact cutout around the target button
/// - Animated subtle glowing pulse border around the spotlight
/// - Animated bobbing pointing finger (👆) directing the user's eye to the button
/// - Optional floating widget preview (e.g. auto-opened dropdown box)
/// - Floating tooltip card with step indicator, dots, Back, Skip, and spacious Next buttons
/// - Responsive edge-clamping (works on mobile, tablet, and web desktop)
/// - Keyboard shortcuts (Esc to skip, Right/Enter for next, Left for back)
class PreviewWalkthroughOverlay extends StatefulWidget {
  final List<WalkthroughStep> steps;
  final VoidCallback onDismiss;

  const PreviewWalkthroughOverlay({
    super.key,
    required this.steps,
    required this.onDismiss,
  });

  @override
  State<PreviewWalkthroughOverlay> createState() =>
      _PreviewWalkthroughOverlayState();
}

class _PreviewWalkthroughOverlayState extends State<PreviewWalkthroughOverlay>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Rect? _targetRect;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  late AnimationController _fingerController;
  late Animation<double> _fingerAnimation;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Pulse animation around the spotlight cutout
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    // Finger bobbing animation (moving up and down to point at the button)
    _fingerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _fingerAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _fingerController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTargetRect();
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fingerController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateTargetRect() {
    if (!mounted || widget.steps.isEmpty) return;
    final currentKey = widget.steps[_currentIndex].key;
    final context = currentKey.currentContext;

    if (context != null) {
      final targetBox = context.findRenderObject() as RenderBox?;
      final overlayBox = this.context.findRenderObject() as RenderBox?;
      if (targetBox != null && targetBox.hasSize) {
        final Offset offset;
        if (overlayBox != null && overlayBox.hasSize) {
          offset = overlayBox.globalToLocal(
            targetBox.localToGlobal(Offset.zero),
          );
        } else {
          offset = targetBox.localToGlobal(Offset.zero);
        }
        setState(() {
          _targetRect = offset & targetBox.size;
        });
        return;
      }
    }

    // Fallback retry if layout isn't settled
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateTargetRect();
    });
  }

  void _next() {
    if (_currentIndex < widget.steps.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _updateTargetRect();
    } else {
      widget.onDismiss();
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _updateTargetRect();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.steps.isEmpty) return const SizedBox.shrink();

    final step = widget.steps[_currentIndex];
    final size = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              widget.onDismiss();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
                event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              _next();
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
              _prev();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Stack(
          children: [
            // ── 1. Scrim with Spotlight Cutout ──
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _next,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _SpotlightPainter(
                        targetRect: _targetRect,
                        pulseValue: _pulseAnimation.value,
                        accentColor: step.accentColor,
                      ),
                      size: size,
                    );
                  },
                ),
              ),
            ),

            // ── 2. Floating Sub-widget Preview (e.g. auto-opened box on Step 2) ──
            if (_targetRect != null && step.floatingWidget != null)
              _buildFloatingWidget(step, size),

            // ── 3. Animated Pointing Finger & Tooltip Card ──
            if (_targetRect != null) _buildCardWithFinger(step, size),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingWidget(WalkthroughStep step, Size screenSize) {
    final target = _targetRect!;
    const double menuWidth = 240.0;
    const double padding = 16.0;

    double menuLeft = target.center.dx - (menuWidth / 2);
    if (menuLeft + menuWidth > screenSize.width - padding) {
      menuLeft = screenSize.width - menuWidth - padding;
    }
    if (menuLeft < padding) menuLeft = padding;

    final double menuTop = target.bottom + 8.0;

    return Positioned(
      left: menuLeft,
      top: menuTop,
      child: Material(color: Colors.transparent, child: step.floatingWidget!),
    );
  }

  Widget _buildCardWithFinger(WalkthroughStep step, Size screenSize) {
    final target = _targetRect!;
    final double cardWidth = (screenSize.width - 32.0).clamp(320.0, 380.0);
    const double padding = 16.0;

    // Center card under target rect, clamping within screen bounds
    double cardLeft = target.center.dx - (cardWidth / 2);
    if (cardLeft < padding) {
      cardLeft = padding;
    } else if (cardLeft + cardWidth > screenSize.width - padding) {
      cardLeft = screenSize.width - cardWidth - padding;
    }

    // Position below target button (plus extra clearance if a floating menu is shown)
    const double fingerHeight = 36.0;
    final double extraOffset = step.floatingWidget != null ? 116.0 : 0.0;
    double cardTop = target.bottom + extraOffset + fingerHeight + 14.0;
    if (cardTop + 280.0 > screenSize.height - padding) {
      cardTop = (screenSize.height - 280.0 - padding).clamp(
        padding,
        screenSize.height,
      );
    }

    // Arrow pointer horizontal offset relative to the card
    final double arrowLeft = (target.center.dx - cardLeft).clamp(
      24.0,
      cardWidth - 24.0,
    );

    return Positioned(
      left: cardLeft,
      top: cardTop,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Pointing Finger (👆 Animated gesture) ──
          AnimatedBuilder(
            animation: _fingerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  arrowLeft - 18,
                  -fingerHeight - 4 + _fingerAnimation.value,
                ),
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Material(
                type: MaterialType.transparency,
                child: Text(
                  '👆',
                  style: TextStyle(
                    inherit: false,
                    fontSize: 22,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ),

          // ── Card Container ──
          Material(
            color: Colors.transparent,
            child: Container(
              width: cardWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x330F172A),
                    blurRadius: 28,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Little Top Arrow Triangle
                  Positioned(
                    top: -7,
                    left: arrowLeft - 7,
                    child: CustomPaint(
                      size: const Size(14, 8),
                      painter: _ArrowPainter(color: Colors.white),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header Row: Icon + Badge + Skip & Close
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: step.iconBgColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                step.icon,
                                color: step.accentColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'STEP ${_currentIndex + 1} OF ${widget.steps.length}',
                                style: const TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: AuthTheme.textSecondary,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            // Skip text button
                            TextButton(
                              onPressed: widget.onDismiss,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Skip',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Title
                        Text(
                          step.title,
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AuthTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Description
                        if (step.description.isNotEmpty) ...[
                          Text(
                            step.description,
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 13,
                              height: 1.4,
                              fontWeight: FontWeight.w400,
                              color: AuthTheme.textSecondary,
                            ),
                          ),
                        ],

                        // Custom Content (e.g. breakdown of options)
                        if (step.customContent != null) ...[
                          const SizedBox(height: 10),
                          step.customContent!,
                        ],

                        const SizedBox(height: 18),

                        // Bottom Controls Row: Dots Indicator on Left, Back & Next on Right
                        Row(
                          children: [
                            // Step Indicator Dots
                            Row(
                              children: List.generate(widget.steps.length, (
                                index,
                              ) {
                                final isActive = index == _currentIndex;
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  margin: const EdgeInsets.only(right: 5),
                                  width: isActive ? 18 : 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AuthTheme.primary
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                );
                              }),
                            ),
                            const Spacer(),

                            // Back Button (shown from step 2 onward)
                            if (_currentIndex > 0) ...[
                              TextButton(
                                onPressed: _prev,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  minimumSize: const Size(60, 40),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AuthTheme.textSecondary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],

                            // Next / Done CTA (Bigger, spacious, and comfortable)
                            ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AuthTheme.primary,
                                foregroundColor: Colors.white,
                                elevation: 3,
                                shadowColor: AuthTheme.primary.withValues(
                                  alpha: 0.35,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 10,
                                ),
                                minimumSize: const Size(96, 40),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _currentIndex < widget.steps.length - 1
                                        ? 'Next'
                                        : 'Got it',
                                    style: const TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _currentIndex < widget.steps.length - 1
                                        ? '👉'
                                        : '🎉',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter that dims the background and carves out a rounded spotlight around the target button
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final double pulseValue;
  final Color accentColor;

  _SpotlightPainter({
    required this.targetRect,
    required this.pulseValue,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color =
          const Color(0x9E0F172A) // 62% dark slate scrim
      ..style = PaintingStyle.fill;

    if (targetRect == null) {
      canvas.drawRect(Offset.zero & size, backgroundPaint);
      return;
    }

    // Expand target rect slightly for breathing room
    final spotlightRect = targetRect!.inflate(4.0);
    final rrect = RRect.fromRectAndRadius(
      spotlightRect,
      const Radius.circular(14),
    );

    // Cut hole using Path.combine difference
    final fullPath = Path()..addRect(Offset.zero & size);
    final holePath = Path()..addRRect(rrect);
    final combinedPath = Path.combine(
      PathOperation.difference,
      fullPath,
      holePath,
    );

    canvas.drawPath(combinedPath, backgroundPaint);

    // Subtle animated glowing pulse ring
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35 + (0.25 * pulseValue))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5 + (1.5 * pulseValue);

    canvas.drawRRect(rrect, glowPaint);
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.pulseValue != pulseValue ||
        oldDelegate.accentColor != accentColor;
  }
}

/// Upward-pointing triangle painter for the card caret
class _ArrowPainter extends CustomPainter {
  final Color color;

  _ArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => false;
}
