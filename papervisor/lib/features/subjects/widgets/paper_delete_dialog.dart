import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Clean confirmation dialog for deleting a generated or reference paper.
class PaperDeleteDialog extends StatefulWidget {
  final String paperTitle;
  final bool isAi;
  final Future<void> Function() onConfirmDelete;

  const PaperDeleteDialog({
    super.key,
    required this.paperTitle,
    this.isAi = true,
    required this.onConfirmDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required String paperTitle,
    bool isAi = true,
    required Future<void> Function() onConfirmDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => PaperDeleteDialog(
        paperTitle: paperTitle,
        isAi: isAi,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<PaperDeleteDialog> createState() => _PaperDeleteDialogState();
}

class _PaperDeleteDialogState extends State<PaperDeleteDialog> {
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
    final title = widget.isAi ? 'Delete Paper?' : 'Delete Reference Paper?';

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
              title,
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
              'Are you sure you want to delete "${widget.paperTitle}"? This action cannot be undone.',
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
