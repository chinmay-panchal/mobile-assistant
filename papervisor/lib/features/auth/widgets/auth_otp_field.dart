import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/auth_theme.dart';

/// 6-digit OTP input widget with automatic focus progression,
/// backspace handling, and paste support.
class AuthOtpField extends StatefulWidget {
  final int length;
  final TextEditingController controller;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const AuthOtpField({
    super.key,
    this.length = 6,
    required this.controller,
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<AuthOtpField> createState() => _AuthOtpFieldState();
}

class _AuthOtpFieldState extends State<AuthOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<FocusNode> _keyboardFocusNodes;
  bool _internalUpdate = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _keyboardFocusNodes = List.generate(widget.length, (_) => FocusNode());

    // Sync from parent controller
    _syncFromParent();
    widget.controller.addListener(_onParentControllerChanged);
  }

  void _onParentControllerChanged() {
    if (_internalUpdate) return;
    _syncFromParent();
  }

  void _syncFromParent() {
    final text = widget.controller.text;
    for (int i = 0; i < widget.length; i++) {
      final char = i < text.length ? text[i] : '';
      if (_controllers[i].text != char) {
        _controllers[i].text = char;
      }
    }
    if (text.length == widget.length) {
      widget.onCompleted?.call(text);
    }
  }

  void _updateParent() {
    _internalUpdate = true;
    final combined = _controllers.map((c) => c.text).join();
    widget.controller.text = combined;
    widget.onChanged?.call(combined);
    if (combined.length == widget.length) {
      widget.onCompleted?.call(combined);
    }
    _internalUpdate = false;
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onParentControllerChanged);
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    for (final f in _keyboardFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < widget.length; i++) {
        final char = i < digits.length ? digits[i] : '';
        _controllers[i].text = char;
      }
      _updateParent();
      final nextIndex = digits.length < widget.length
          ? digits.length
          : widget.length - 1;
      _focusNodes[nextIndex].requestFocus();
      return;
    }

    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
    _updateParent();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return _buildDigitBox(index);
      }),
    );
  }

  Widget _buildDigitBox(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: KeyboardListener(
        focusNode: _keyboardFocusNodes[index],
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              _controllers[index].text.isEmpty &&
              index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
        child: AnimatedBuilder(
          animation: _focusNodes[index],
          builder: (context, _) {
            final isFocused = _focusNodes[index].hasFocus;
            final hasValue = _controllers[index].text.isNotEmpty;
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E293B)
                    : (isFocused ? Colors.white : AuthTheme.inputBg),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFocused
                      ? (isDark ? const Color(0xFF38BDF8) : AuthTheme.primary)
                      : (hasValue
                            ? (isDark
                                  ? Colors.white70
                                  : AuthTheme.primary.withValues(alpha: 0.5))
                            : (isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFCBD5E1))),
                  width: isFocused ? 2.0 : 1.5,
                ),
                boxShadow: isFocused
                    ? (isDark
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF38BDF8,
                                ).withValues(alpha: 0.25),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ]
                          : AuthTheme.fieldFocusShadow)
                    : null,
              ),
              child: Center(
                child: TextField(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFF8FAFC)
                        : AuthTheme.textPrimary,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6), // Allow paste
                  ],
                  cursorColor: isDark
                      ? const Color(0xFF38BDF8)
                      : AuthTheme.primary,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (val) => _onDigitChanged(index, val),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
