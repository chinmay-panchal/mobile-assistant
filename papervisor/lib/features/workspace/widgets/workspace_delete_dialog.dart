import 'package:flutter/material.dart';
import '../constants/workspace_theme.dart';
import 'workspace_primary_button.dart';

/// Clean confirmation dialog for workspace deletion.
class WorkspaceDeleteDialog extends StatefulWidget {
  final String workspaceName;
  final Future<void> Function() onConfirmDelete;

  const WorkspaceDeleteDialog({
    super.key,
    required this.workspaceName,
    required this.onConfirmDelete,
  });

  static Future<void> show({
    required BuildContext context,
    required String workspaceName,
    required Future<void> Function() onConfirmDelete,
  }) {
    return showDialog(
      context: context,
      builder: (_) => WorkspaceDeleteDialog(
        workspaceName: workspaceName,
        onConfirmDelete: onConfirmDelete,
      ),
    );
  }

  @override
  State<WorkspaceDeleteDialog> createState() => _WorkspaceDeleteDialogState();
}

class _WorkspaceDeleteDialogState extends State<WorkspaceDeleteDialog> {
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
            backgroundColor: WorkspaceTheme.error,
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: const TextStyle(fontFamily: WorkspaceTheme.fontFamily),
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
      backgroundColor: WorkspaceTheme.surfaceWhite,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.errorLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: WorkspaceTheme.errorBorder),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: WorkspaceTheme.error,
                  size: 24,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Workspace?',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: WorkspaceTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to delete "${widget.workspaceName}"? All subjects and exam papers inside will be permanently removed.',
                style: const TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: WorkspaceTheme.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: WorkspacePrimaryButton(
                      text: 'Cancel',
                      isSecondary: true,
                      height: 44,
                      onPressed: _isDeleting ? null : () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: WorkspacePrimaryButton(
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
