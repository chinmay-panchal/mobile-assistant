import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Floating bottom input composer for querying PYQs.
class ExploreInputComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final VoidCallback onSubmit;

  const ExploreInputComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AuthTheme.inputBorder, width: 1),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      child: Container(
        decoration: ShapeDecoration(
          color: const Color(0xFFF8FAFC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthTheme.radiusField),
            side: const BorderSide(color: AuthTheme.inputBorder, width: 1.0),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.only(left: 18, right: 6, top: 4, bottom: 4),
        child: Row(
          children: [
            // Search Icon
            const Icon(
              Icons.search_rounded,
              color: AuthTheme.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 10),

            // Text input
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: !isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AuthTheme.textPrimary,
                ),
                decoration: const InputDecoration(
                  hintText: 'Ask for a PYQ (e.g. Physics 2024)...',
                  hintStyle: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                  isDense: true,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Integrated Send Button
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, val, _) {
                final hasText = val.text.trim().isNotEmpty;
                final canSend = hasText && !isLoading;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: canSend ? AuthTheme.primaryGradient : null,
                    color: canSend ? null : const Color(0xFFE2E8F0),
                    boxShadow: canSend
                        ? [
                            BoxShadow(
                              color: AuthTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: canSend ? onSubmit : null,
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Icon(
                                Icons.arrow_upward_rounded,
                                size: 20,
                                color: canSend ? Colors.white : const Color(0xFF94A3B8),
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
