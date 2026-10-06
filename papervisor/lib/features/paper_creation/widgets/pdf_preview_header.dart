import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
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
  final VoidCallback? onEditContent;
  final VoidCallback? onVisualDesigner;
  final VoidCallback? onAddImageText;
  final VoidCallback onPrint;
  final VoidCallback onShare;
  final VoidCallback? onStartTour;
  final GlobalKey? saveKey;
  final GlobalKey? editKey;
  final GlobalKey? printKey;
  final GlobalKey? shareKey;

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
    this.onEditContent,
    this.onVisualDesigner,
    this.onAddImageText,
    required this.onPrint,
    required this.onShare,
    this.onStartTour,
    this.saveKey,
    this.editKey,
    this.printKey,
    this.shareKey,
  });

  @override
  Widget build(BuildContext context) {
    final showWebBack = kIsWeb && !Responsive.isMobile(context);

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
            // Optional Back Navigation Button (Shown on Web Desktop/Tablet only, hidden on phones)
            if (onBack != null && showWebBack) ...[
              Tooltip(
                message: 'Back',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: AuthTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
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
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AuthTheme.primary,
                        ),
                      ),
                    )
                  else if (onSave != null)
                    KeyedSubtree(
                      key: saveKey,
                      child: _buildIconButton(
                        icon: Icons.cloud_upload_outlined,
                        tooltip: 'Save PDF',
                        isPrimary: true,
                        onTap: onSave!,
                      ),
                    ),

                  // Edit Button / Menu (little box beside the edit icon)
                  if (onEditContent != null ||
                      onVisualDesigner != null ||
                      onAddImageText != null) ...[
                    const SizedBox(width: 6),
                    KeyedSubtree(
                      key: editKey,
                      child: _buildEditPopupMenu(context),
                    ),
                  ] else if (onEdit != null) ...[
                    const SizedBox(width: 6),
                    KeyedSubtree(
                      key: editKey,
                      child: _buildIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Edit Paper',
                        onTap: onEdit!,
                      ),
                    ),
                  ],
                ],

                const SizedBox(width: 6),

                // ── Print Button ──
                KeyedSubtree(
                  key: printKey,
                  child: _buildIconButton(
                    icon: Icons.print_outlined,
                    tooltip: 'Print',
                    onTap: onPrint,
                  ),
                ),

                const SizedBox(width: 6),

                // ── Share Button ──
                KeyedSubtree(
                  key: shareKey,
                  child: _buildIconButton(
                    icon: Icons.share_outlined,
                    tooltip: 'Share',
                    onTap: onShare,
                  ),
                ),

                if (onStartTour != null) ...[
                  const SizedBox(width: 6),
                  _buildIconButton(
                    icon: Icons.help_outline_rounded,
                    tooltip: 'Preview Walkthrough',
                    onTap: onStartTour!,
                  ),
                ],
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

  Widget _buildEditPopupMenu(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: const Color(0xFFF1F5F9),
        splashColor: const Color(0xFFE2E8F0),
        dividerColor: const Color(0xFFF1F5F9),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFF1F5F9),
          thickness: 1,
          space: 1,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: 'Edit Paper',
        offset: const Offset(0, 46),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        color: Colors.white,
        onSelected: (value) {
          if (value == 'edit_content') {
            onEditContent?.call();
          } else if (value == 'visual_designer') {
            onVisualDesigner?.call();
            onAddImageText?.call();
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem<String>(
            value: 'edit_content',
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFDBEAFE)),
                  ),
                  child: const Icon(
                    Icons.edit_note_rounded,
                    size: 17,
                    color: AuthTheme.primary,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Edit content',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AuthTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _SubtleMenuDivider(),
          PopupMenuItem<String>(
            value: 'visual_designer',
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDFA),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCCFBF1)),
                  ),
                  child: const Icon(
                    Icons.design_services_rounded,
                    size: 17,
                    color: Color(0xFF0D9488),
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Visual Designer',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AuthTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AuthTheme.inputBorder.withValues(alpha: 0.9),
            ),
          ),
          child: const Icon(
            Icons.edit_outlined,
            size: 18,
            color: AuthTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Very light, subtle divider for popup menus
class _SubtleMenuDivider extends PopupMenuEntry<Never> {
  const _SubtleMenuDivider();

  @override
  final double height = 1;

  @override
  bool represents(void value) => false;

  @override
  State<_SubtleMenuDivider> createState() => _SubtleMenuDividerState();
}

class _SubtleMenuDividerState extends State<_SubtleMenuDivider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: const Color(0xFFF1F5F9),
    );
  }
}
