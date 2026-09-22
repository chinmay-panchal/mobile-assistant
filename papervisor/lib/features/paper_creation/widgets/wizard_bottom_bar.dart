import 'package:flutter/material.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Sticky bottom action bar used across all Paper Creation Wizard steps.
/// Provides a consistent, elevated action container with optional helper/status
/// badges and the primary action button.
class WizardBottomBar extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Widget? helperWidget;

  const WizardBottomBar({
    super.key,
    this.text = 'Continue',
    required this.onPressed,
    this.isLoading = false,
    this.icon = Icons.arrow_forward_rounded,
    this.helperWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (helperWidget != null) ...[
            helperWidget!,
            const SizedBox(height: 10),
          ],
          AuthPrimaryButton(
            text: text,
            onPressed: onPressed,
            isLoading: isLoading,
            icon: icon != null ? Icon(icon, color: Colors.white, size: 18) : null,
            height: 52,
          ),
        ],
      ),
    );
  }
}
