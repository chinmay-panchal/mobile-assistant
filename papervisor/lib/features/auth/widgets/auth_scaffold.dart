import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../theme/auth_theme.dart';

/// Reusable layout wrapper providing a soft ambient pastel background,
/// responsive scrolling, and keyboard overflow protection.
/// Enforces light theme aesthetics across all auth workflows.
class AuthScaffold extends StatelessWidget {
  final Widget child;
  final Widget? topBar;
  final EdgeInsetsGeometry padding;
  final bool resizeToAvoidBottomInset;

  const AuthScaffold({
    super.key,
    required this.child,
    this.topBar,
    this.padding = const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        backgroundColor: AuthTheme.background,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: Stack(
          children: [
            // Ambient Pastel Blobs in Background
            Positioned(
              top: -60,
              right: -60,
              child: _buildAmbientBlob(
                size: size.width * 0.75,
                color: AuthTheme.pastelBlue.withValues(alpha: 0.65),
              ),
            ),
            Positioned(
              top: size.height * 0.12,
              left: -80,
              child: _buildAmbientBlob(
                size: size.width * 0.7,
                color: AuthTheme.pastelPurple.withValues(alpha: 0.45),
              ),
            ),
            Positioned(
              bottom: -50,
              right: -40,
              child: _buildAmbientBlob(
                size: size.width * 0.65,
                color: AuthTheme.pastelPink.withValues(alpha: 0.35),
              ),
            ),
            Positioned(
              bottom: size.height * 0.25,
              left: -60,
              child: _buildAmbientBlob(
                size: size.width * 0.55,
                color: AuthTheme.pastelMint.withValues(alpha: 0.40),
              ),
            ),

            // Glassmorphism Blur Layer to blend ambient pastels softly
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 55, sigmaY: 55),
                child: Container(color: Colors.transparent),
              ),
            ),

            // Foreground Content
            SafeArea(
              child: Column(
                children: [
                  ?topBar,
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: padding,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmbientBlob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
