import 'package:flutter/material.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Clean, seamless bottom action bar used across all Paper Creation Wizard steps.
/// Fits directly into the screen canvas without a rectangular white box or border.
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
        8,
        20,
        16 + MediaQuery.of(context).padding.bottom,
      ),
      color: Colors.transparent,
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
