import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/theme/auth_theme.dart';

/// Redesigned action panel for customizing a paper:
/// Institution Logo, Edit Paper Content, and Visual Designer (Drag & Drop).
class PdfEditSheet extends StatelessWidget {
  final Uint8List? logoBytes;
  final VoidCallback onPickLogo;
  final VoidCallback onRemoveLogo;
  final VoidCallback onEditContent;
  final VoidCallback onOpenVisualDesigner;
  final bool isDialog;

  const PdfEditSheet({
    super.key,
    required this.logoBytes,
    required this.onPickLogo,
    required this.onRemoveLogo,
    required this.onEditContent,
    required this.onOpenVisualDesigner,
    this.isDialog = false,
  });

  static Future<void> show({
    required BuildContext context,
    required Uint8List? logoBytes,
    required VoidCallback onPickLogo,
    required VoidCallback onRemoveLogo,
    required VoidCallback onEditContent,
    required VoidCallback onOpenVisualDesigner,
  }) {
    return AdaptiveModal.show(
      context: context,
      maxWidth: 520,
      builder: (ctx, isDialog) => PdfEditSheet(
        logoBytes: logoBytes,
        onPickLogo: onPickLogo,
        onRemoveLogo: onRemoveLogo,
        onEditContent: onEditContent,
        onOpenVisualDesigner: onOpenVisualDesigner,
        isDialog: isDialog,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isDialog
            ? BorderRadius.circular(24)
            : const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        isDialog ? 22 : 14,
        22,
        isDialog ? 24 : MediaQuery.of(context).viewInsets.bottom + 26,
      ),
      child: SafeArea(
        top: false,
        bottom: !isDialog,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDialog) ...[
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
                const SizedBox(height: 18),
              ],

              // Header Title & Subtitle with optional close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Edit Paper',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AuthTheme.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Choose what you’d like to change.',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: AuthTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isDialog)
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
              const SizedBox(height: 20),

              // ── Option 1: Institution Logo Card ──
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    // Logo Preview Thumbnail
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: logoBytes != null
                              ? const Color(0xFF818CF8)
                              : const Color(0xFFCBD5E1),
                          width: logoBytes != null ? 1.5 : 1,
                        ),
                      ),
                      child: logoBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                logoBytes!,
                                fit: BoxFit.contain,
                              ),
                            )
                          : const Icon(
                              Icons.school_rounded,
                              color: AuthTheme.textTertiary,
                              size: 24,
                            ),
                    ),

                    const SizedBox(width: 14),

                    // Info & Action Buttons
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Institution Logo',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AuthTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            logoBytes != null
                                ? 'Logo active in top-right of PDF'
                                : 'Add or update institution branding.',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                              color: logoBytes != null
                                  ? AuthTheme.success
                                  : AuthTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              // Upload / Change Button
                              InkWell(
                                onTap: onPickLogo,
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AuthTheme.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    logoBytes != null ? 'Change' : 'Upload',
                                    style: const TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),

                              if (logoBytes != null) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: onRemoveLogo,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AuthTheme.errorLight,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: AuthTheme.errorBorder,
                                      ),
                                    ),
                                    child: const Text(
                                      'Remove',
                                      style: TextStyle(
                                        fontFamily: AuthTheme.fontFamily,
                                        color: AuthTheme.error,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ── Option 2: Edit Paper Content Card ──
              _buildOptionTile(
                icon: Icons.edit_document,
                iconColor: const Color(0xFF0284C7),
                iconBg: const Color(0xFFE0F2FE),
                title: 'Edit Paper Content',
                subtitle: 'Edit title, questions, marks, and time.',
                onTap: onEditContent,
              ),

              const SizedBox(height: 12),

              // ── Option 3: Visual Designer (Drag & Drop) ──
              _buildOptionTile(
                icon: Icons.design_services_rounded,
                iconColor: const Color(0xFF6D28D9),
                iconBg: const Color(0xFFEDE9FE),
                title: 'Visual Designer',
                subtitle: 'Drag and position visual elements on the paper.',
                onTap: onOpenVisualDesigner,
              ),

              const SizedBox(height: 16),

              // Regeneration helper note
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AuthTheme.primary,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'PDF will regenerate automatically after changes.',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 11,
                          color: AuthTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AuthTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AuthTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AuthTheme.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
