import 'package:flutter/material.dart';
import '../theme/auth_theme.dart';

/// Modern primary call-to-action button featuring smooth gradient styling,
/// tactile press scaling, and elegant loading spinner transitions.
class AuthPrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool isSecondary;
  final bool isDestructive;
  final double height;

  const AuthPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isSecondary = false,
    this.isDestructive = false,
    this.height = 54.0,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
          gradient: (widget.isSecondary || widget.isDestructive)
              ? null
              : (_isEnabled ? AuthTheme.primaryGradient : null),
          color: widget.isDestructive
              ? (_isEnabled ? AuthTheme.error : AuthTheme.inputBorder)
              : (widget.isSecondary
                  ? AuthTheme.surfaceWhite
                  : (_isEnabled ? null : AuthTheme.inputBorder)),
          border: widget.isSecondary
              ? Border.all(color: AuthTheme.inputBorder, width: 1.2)
              : null,
          boxShadow: _isEnabled && !widget.isSecondary
              ? (widget.isDestructive
                  ? [
                      BoxShadow(
                        color: AuthTheme.error.withValues(alpha: 0.25),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ]
                  : AuthTheme.buttonShadow)
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
            onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
            onTap: _isEnabled ? widget.onPressed : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: widget.isLoading
                    ? SizedBox(
                        key: const ValueKey('loader'),
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isSecondary ? AuthTheme.primary : Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        key: const ValueKey('content'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              widget.text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: widget.isDestructive
                                  ? const TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    )
                                  : (widget.isSecondary
                                      ? const TextStyle(
                                          fontFamily: AuthTheme.fontFamily,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: AuthTheme.textPrimary,
                                        )
                                      : AuthTheme.buttonText),
                            ),
                          ),
                          if (widget.icon != null) ...[
                            const SizedBox(width: 8),
                            widget.icon!,
                          ],
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
