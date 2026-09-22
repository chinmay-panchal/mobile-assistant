import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/auth_theme.dart';

/// Modern, tactile text input field featuring soft rounded corners,
/// focus glow, clean prefix icons, and password visibility toggling.
class AuthTextField extends StatefulWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextEditingController? controller;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? suffix;

  const AuthTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.controller,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.inputFormatters,
    this.suffix,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscureText;
  late FocusNode _internalFocusNode;
  bool _isFocused = false;

  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _effectiveFocusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AuthTheme.inputLabel,
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AuthTheme.radiusField),
            boxShadow: hasError
                ? [
                    BoxShadow(
                      color: AuthTheme.error.withValues(alpha: 0.12),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : (_isFocused ? AuthTheme.fieldFocusShadow : null),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _effectiveFocusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction ?? TextInputAction.next,
            inputFormatters: widget.inputFormatters,
            obscureText: widget.isPassword && _obscureText,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            style: AuthTheme.inputText,
            cursorColor: AuthTheme.accentSky,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AuthTheme.inputBg,
              hintText: widget.hintText,
              hintStyle: AuthTheme.inputHint,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                borderSide: const BorderSide(
                  color: AuthTheme.inputBorder,
                  width: 1.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                borderSide: BorderSide(
                  color: hasError ? AuthTheme.error : AuthTheme.inputBorder,
                  width: 1.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                borderSide: BorderSide(
                  color: hasError ? AuthTheme.error : AuthTheme.inputFocusBorder,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                borderSide: const BorderSide(
                  color: AuthTheme.error,
                  width: 1.0,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                borderSide: const BorderSide(
                  color: AuthTheme.error,
                  width: 1.5,
                ),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      size: 20,
                      color: _isFocused ? AuthTheme.accentSky : AuthTheme.textTertiary,
                    )
                  : null,
              suffixIcon: widget.suffix ??
                  (widget.isPassword
                      ? IconButton(
                          splashRadius: 20,
                          icon: Icon(
                            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 20,
                            color: AuthTheme.textTertiary,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        )
                      : null),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, size: 14, color: AuthTheme.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AuthTheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
