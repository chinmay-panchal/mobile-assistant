import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Clean confirmation dialog for subject deletion.
class SubjectDeleteDialog extends StatefulWidget {
  final String subjectName;
  final Future<void> Function() onConfirmDelete;

  const SubjectDeleteDialog({
    super.key,
    required this.subjectName,
    required this.onConfirmDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required String subjectName,
    required Future<void> Function() onConfirmDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => SubjectDeleteDialog(
        subjectName: subjectName,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<SubjectDeleteDialog> createState() => _SubjectDeleteDialogState();
}

class _SubjectDeleteDialogState extends State<SubjectDeleteDialog> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirmDelete();
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              // Destructive Alert Icon
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

              // Dialog Title
              const Text(
                'Delete Subject?',
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AuthTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Are you sure you want to delete "${widget.subjectName}"? This action cannot be undone and all books inside will be permanently deleted.',
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

              // Action Buttons: Cancel and Delete
              Row(
                children: [
                  Expanded(
                    child: AuthPrimaryButton(
                      text: 'Cancel',
                      isSecondary: true,
                      height: 44,
                      onPressed: _isDeleting ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AuthPrimaryButton(
                      text: 'Delete',
                      isDestructive: true,
                      height: 44,
                      isLoading: _isDeleting,
                      onPressed: _handleDelete,
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
