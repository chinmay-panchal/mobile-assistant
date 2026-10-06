import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../workspace/widgets/workspace_primary_button.dart';

/// Clean dialog sheet for naming the generated paper, specifying academic class,
/// and setting time allowed in minutes prior to invoking AI generation.
class PaperMetaDialog extends StatefulWidget {
  final String initialTitle;
  final String initialClass;
  final int initialMinutes;
  final void Function(String title, String className, int minutes) onGenerate;

  const PaperMetaDialog({
    super.key,
    this.initialTitle = '',
    this.initialClass = '',
    this.initialMinutes = 90,
    required this.onGenerate,
  });

  static Future<void> show({
    required BuildContext context,
    String initialTitle = '',
    String initialClass = '',
    int initialMinutes = 90,
    required void Function(String title, String className, int minutes)
    onGenerate,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PaperMetaDialog(
        initialTitle: initialTitle,
        initialClass: initialClass,
        initialMinutes: initialMinutes,
        onGenerate: onGenerate,
      ),
    );
  }

  @override
  State<PaperMetaDialog> createState() => _PaperMetaDialogState();
}

class _PaperMetaDialogState extends State<PaperMetaDialog> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _classCtrl;
  late final TextEditingController _minutesCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    _classCtrl = TextEditingController(text: widget.initialClass);
    _minutesCtrl = TextEditingController(
      text: widget.initialMinutes.toString(),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _classCtrl.dispose();
    _minutesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleCtrl.text.trim().isEmpty
        ? 'Exam Paper'
        : _titleCtrl.text.trim();
    final className = _classCtrl.text.trim();
    final minutes = int.tryParse(_minutesCtrl.text.trim()) ?? 90;
    Navigator.of(context).pop();
    widget.onGenerate(title, className, minutes);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: WorkspaceTheme.borderSubtle),
      ),
      backgroundColor: WorkspaceTheme.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon Badge
                Center(
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: WorkspaceTheme.isDark
                          ? const Color(0xFF151F32)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: WorkspaceTheme.borderSubtle),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: WorkspaceTheme.isDark
                          ? const Color(0xFF38BDF8)
                          : WorkspaceTheme.primaryDark,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Subtitle
                Text(
                  'Finalize Paper Details',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: WorkspaceTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Set the title, academic level, and exam duration for your paper header.',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: WorkspaceTheme.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Paper Title Input
                AuthTextField(
                  label: 'Paper Title',
                  hintText: 'e.g. Midterm Examination 2026',
                  controller: _titleCtrl,
                  prefixIcon: Icons.title_rounded,
                ),
                const SizedBox(height: 14),

                // Class & Time Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: AuthTextField(
                        label: 'Class / Level',
                        hintText: 'e.g. Class 10th',
                        controller: _classCtrl,
                        prefixIcon: Icons.school_outlined,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: AuthTextField(
                        label: 'Time (min)',
                        hintText: '90',
                        controller: _minutesCtrl,
                        prefixIcon: Icons.timer_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: WorkspaceTheme.textSecondary,
                          side: BorderSide(color: WorkspaceTheme.borderSubtle),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AuthTheme.radiusPill,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: WorkspacePrimaryButton(
                        text: 'Generate Paper',
                        icon: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        onPressed: _submit,
                        height: 48,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
