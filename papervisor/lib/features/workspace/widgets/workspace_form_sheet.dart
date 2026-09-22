import 'package:flutter/material.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../constants/workspace_theme.dart';
import 'workspace_primary_button.dart';

/// Reusable bottom sheet for creating or editing a workspace.
class WorkspaceFormSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String submitButtonText;
  final String? initialName;
  final Future<void> Function(String name) onSubmit;

  const WorkspaceFormSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.submitButtonText,
    this.initialName,
    required this.onSubmit,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String submitButtonText,
    String? initialName,
    required Future<void> Function(String name) onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkspaceFormSheet(
        title: title,
        subtitle: subtitle,
        submitButtonText: submitButtonText,
        initialName: initialName,
        onSubmit: onSubmit,
      ),
    );
  }

  @override
  State<WorkspaceFormSheet> createState() => _WorkspaceFormSheetState();
}

class _WorkspaceFormSheetState extends State<WorkspaceFormSheet> {
  late final TextEditingController _nameController;
  bool _isLoading = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorText = 'Please enter a workspace name.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      await widget.onSubmit(name);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorText = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.borderMedium,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sheet Title & Description
            Text(
              widget.title,
              style: const TextStyle(
                fontFamily: WorkspaceTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: WorkspaceTheme.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontFamily: WorkspaceTheme.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: WorkspaceTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 22),

            // Workspace Name Input Field
            AuthTextField(
              controller: _nameController,
              label: 'Workspace name',
              hintText: 'e.g. Class 10th Physics',
              prefixIcon: Icons.folder_outlined,
              errorText: _errorText,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 26),

            // Action Buttons Row: Cancel and Submit
            Row(
              children: [
                Expanded(
                  child: WorkspacePrimaryButton(
                    text: 'Cancel',
                    isSecondary: true,
                    height: 46,
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: WorkspacePrimaryButton(
                    text: widget.submitButtonText,
                    isLoading: _isLoading,
                    height: 46,
                    onPressed: _handleSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
