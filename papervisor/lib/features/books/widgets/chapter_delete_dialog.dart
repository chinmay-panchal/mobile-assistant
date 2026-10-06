import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Clean confirmation dialog for chapter deletion.
class ChapterDeleteDialog extends StatefulWidget {
  final String chapterNumber;
  final String chapterName;
  final Future<void> Function() onConfirmDelete;

  const ChapterDeleteDialog({
    super.key,
    required this.chapterNumber,
    required this.chapterName,
    required this.onConfirmDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required String chapterNumber,
    required String chapterName,
    required Future<void> Function() onConfirmDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => ChapterDeleteDialog(
        chapterNumber: chapterNumber,
        chapterName: chapterName,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<ChapterDeleteDialog> createState() => _ChapterDeleteDialogState();
}

class _ChapterDeleteDialogState extends State<ChapterDeleteDialog> {
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
              const Text(
                'Delete Chapter?',
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AuthTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete Chapter ${widget.chapterNumber} ("${widget.chapterName}")? All questions and study content inside will be permanently removed.',
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
