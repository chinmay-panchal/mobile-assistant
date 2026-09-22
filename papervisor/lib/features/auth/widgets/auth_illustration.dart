import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders modern vector illustrations with a subtle entrance fade & slide animation.
class AuthIllustration extends StatelessWidget {
  final String assetPath;
  final double height;
  final double? width;

  const AuthIllustration({
    super.key,
    required this.assetPath,
    this.height = 140.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1.0 - value)),
            child: child,
          ),
        );
      },
      child: SizedBox(
        height: height,
        width: width ?? double.infinity,
        child: Center(
          child: SvgPicture.asset(
            assetPath,
            height: height,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => SizedBox(
              height: height,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
