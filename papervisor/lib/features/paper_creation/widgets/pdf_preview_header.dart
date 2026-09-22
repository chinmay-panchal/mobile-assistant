import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Clean, modern header for the PDF preview screen.
/// Hosts back navigation, document title, and compact action controls (Save, Edit, Print, Share).
class PdfPreviewHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isReadOnly;
  final bool isSaved;
  final bool isSaving;
  final VoidCallback? onBack;
  final VoidCallback? onSave;
  final VoidCallback? onEdit;
  final VoidCallback onPrint;
  final VoidCallback onShare;

  const PdfPreviewHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.isReadOnly = false,
    required this.isSaved,
    required this.isSaving,
    this.onBack,
    this.onSave,
    this.onEdit,
    required this.onPrint,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: AuthTheme.inputBorder.withValues(alpha: 0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Document Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AuthTheme.textPrimary,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AuthTheme.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Actions Cluster
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Saved Badge Indicator ──
                if (isSaved)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AuthTheme.successLight,
                      borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_done_rounded,
                          size: 14,
                          color: AuthTheme.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Saved',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            color: AuthTheme.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Save & Edit (Only when NOT saved and NOT read-only) ──
                if (!isSaved && !isReadOnly) ...[
                  // Save Button / Loader
                  if (isSaving)
                    Container(
                      width: 38,
                      height: 38,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AuthTheme.primary),
                      ),
                    )
                  else if (onSave != null)
                    _buildIconButton(
                      icon: Icons.cloud_upload_outlined,
                      tooltip: 'Save PDF',
                      isPrimary: true,
                      onTap: onSave!,
                    ),

                  // Edit Button
                  if (onEdit != null) ...[
                    const SizedBox(width: 6),
                    _buildIconButton(
                      icon: Icons.edit_outlined,
                      tooltip: 'Edit Paper',
                      onTap: onEdit!,
                    ),
                  ],
                ],

                const SizedBox(width: 6),

                // ── Print Button ──
                _buildIconButton(
                  icon: Icons.print_outlined,
                  tooltip: 'Print',
                  onTap: onPrint,
                ),

                const SizedBox(width: 6),

                // ── Share Button ──
                _buildIconButton(
                  icon: Icons.share_outlined,
                  tooltip: 'Share',
                  onTap: onShare,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    double size = 18,
    bool isPrimary = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isPrimary ? AuthTheme.primary : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isPrimary
                    ? AuthTheme.primary
                    : AuthTheme.inputBorder.withValues(alpha: 0.9),
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AuthTheme.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: size,
              color: isPrimary ? Colors.white : AuthTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
