import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Clean confirmation dialog for deleting individual or all PYQ download history items.
class HistoryDeleteDialog extends StatefulWidget {
  final String title;
  final String message;
  final String confirmText;
  final Future<void> Function() onConfirm;

  const HistoryDeleteDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.onConfirm,
  });

  static Future<void> showItemDelete({
    required BuildContext context,
    required String pdfTitle,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => HistoryDeleteDialog(
        title: 'Delete this PDF?',
        message:
            'Are you sure you want to delete "$pdfTitle"? This item will be removed from your history and local storage.',
        confirmText: 'Delete',
        onConfirm: onConfirm,
      ),
    );
  }

  static Future<void> showDeleteAll({
    required BuildContext context,
    required Future<void> Function() onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (_) => HistoryDeleteDialog(
        title: 'Delete all history?',
        message:
            'All downloaded PYQ history and files will be permanently removed from this device.',
        confirmText: 'Delete All',
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<HistoryDeleteDialog> createState() => _HistoryDeleteDialogState();
}

class _HistoryDeleteDialogState extends State<HistoryDeleteDialog> {
  bool _isDeleting = false;

  Future<void> _handleConfirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: AuthTheme.error,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: AuthTheme.fontFamily),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AuthTheme.errorLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AuthTheme.errorBorder),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AuthTheme.error,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AuthTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.message,
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: AuthTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: AuthPrimaryButton(
                      text: 'Cancel',
                      isSecondary: true,
                      height: 44,
                      onPressed: _isDeleting
                          ? null
                          : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthPrimaryButton(
                      text: widget.confirmText,
                      isDestructive: true,
                      height: 44,
                      isLoading: _isDeleting,
                      onPressed: _handleConfirm,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
