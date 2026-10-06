import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';
import '../../auth/widgets/auth_text_field.dart';

/// Reusable bottom sheet for creating or editing a book.
/// Contains only a single input field: Book name.
class BookFormSheet extends StatefulWidget {
  final String title;
  final String subtitle;
  final String submitButtonText;
  final String? initialName;
  final Future<void> Function(String name) onSubmit;

  final bool isDialog;

  const BookFormSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.submitButtonText,
    this.initialName,
    required this.onSubmit,
    this.isDialog = false,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String submitButtonText,
    String? initialName,
    required Future<void> Function(String name) onSubmit,
  }) {
    return AdaptiveModal.show(
      context: context,
      maxWidth: 480,
      builder: (ctx, isDialog) => BookFormSheet(
        title: title,
        subtitle: subtitle,
        submitButtonText: submitButtonText,
        initialName: initialName,
        onSubmit: onSubmit,
        isDialog: isDialog,
      ),
    );
  }

  @override
  State<BookFormSheet> createState() => _BookFormSheetState();
}

class _BookFormSheetState extends State<BookFormSheet> {
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
      setState(() => _errorText = 'Please enter a book name.');
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
        top: widget.isDialog ? 22 : 14,
        bottom:
            MediaQuery.of(context).viewInsets.bottom +
            (widget.isDialog ? 24 : 24),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: widget.isDialog
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        bottom: !widget.isDialog,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!widget.isDialog) ...[
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AuthTheme.inputBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Sheet Title & Description with optional close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AuthTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.isDialog)
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AuthTheme.textSecondary,
                    ),
                    splashRadius: 18,
                    tooltip: 'Close',
                  ),
              ],
            ),
            const SizedBox(height: 22),

            // Book Name Input Field
            AuthTextField(
              controller: _nameController,
              label: 'Book name',
              hintText: 'e.g. Engineering Physics Vol 1',
              prefixIcon: Icons.menu_book_outlined,
              errorText: _errorText,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _handleSubmit(),
            ),
            const SizedBox(height: 26),

            // Action Buttons Row: Cancel and Submit
            Row(
              children: [
                Expanded(
                  child: AuthPrimaryButton(
                    text: 'Cancel',
                    isSecondary: true,
                    height: 48,
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AuthPrimaryButton(
                    text: widget.submitButtonText,
                    isLoading: _isLoading,
                    height: 48,
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
