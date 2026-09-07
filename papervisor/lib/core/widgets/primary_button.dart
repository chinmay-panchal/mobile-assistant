import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSecondary;
  final Widget? icon;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isSecondary = false,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = isSecondary ? theme.colorScheme.surface : theme.colorScheme.primary;
    final textColor = isSecondary ? theme.colorScheme.onSurface : theme.colorScheme.onPrimary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          side: isSecondary ? BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.1)) : null,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: icon == null
            ? Text(
                text,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
      ),
    );
  }
}
