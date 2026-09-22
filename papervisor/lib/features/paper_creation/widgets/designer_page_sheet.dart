import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Bottom sheet for selecting a target page to place text or image elements.
class DesignerPageSheet extends StatelessWidget {
  final int pageCount;
  final bool isText;
  final ValueChanged<int> onPageSelected;

  const DesignerPageSheet({
    super.key,
    required this.pageCount,
    required this.isText,
    required this.onPageSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required int pageCount,
    required bool isText,
    required ValueChanged<int> onPageSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DesignerPageSheet(
        pageCount: pageCount,
        isText: isText,
        onPageSelected: onPageSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = isText ? 'Add Text' : 'Add Image';
    final icon = isText ? Icons.text_fields_rounded : Icons.image_outlined;
    final accentColor = isText ? const Color(0xFF0284C7) : const Color(0xFF6D28D9);
    final iconBg = isText ? const Color(0xFFE0F2FE) : const Color(0xFFEDE9FE);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        14,
        22,
        MediaQuery.of(context).viewInsets.bottom + 26,
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
                  color: AuthTheme.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header
            Text(
              title,
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AuthTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose the page where you want to place the element.',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AuthTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // Pages List
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pageCount,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pop(context);
                          onPageSelected(index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14.0,
                            vertical: 12.0,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: iconBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: accentColor, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Page ${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AuthTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AuthTheme.textTertiary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
