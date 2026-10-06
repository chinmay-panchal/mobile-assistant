import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';

/// Modal dialog/card shown when Gemini asks for clarification on a search prompt.
class ExploreClarificationCard extends StatefulWidget {
  final dynamic request; // ClarificationRequest
  final void Function(String) onSubmit;

  const ExploreClarificationCard({
    super.key,
    required this.request,
    required this.onSubmit,
  });

  @override
  State<ExploreClarificationCard> createState() =>
      _ExploreClarificationCardState();
}

class _ExploreClarificationCardState extends State<ExploreClarificationCard> {
  final TextEditingController _otherCtrl = TextEditingController();

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  void _submitCustom() {
    final text = _otherCtrl.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit(text);
    } else {
      widget.onSubmit('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.request.question ?? 'Please clarify your search:';
    final options =
        (widget.request.options as List<dynamic>?)?.cast<String>() ?? [];
    final stepIndex = widget.request.stepIndex ?? 1;
    final totalSteps = widget.request.totalSteps ?? 1;

    return Container(
      color: Colors.black.withValues(alpha: 0.35),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
              border: Border.all(color: AuthTheme.inputBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.help_outline_rounded,
                          size: 20,
                          color: AuthTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question,
                              style: const TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                color: AuthTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Select an option to refine your paper search',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                color: AuthTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Step Pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(
                            AuthTheme.radiusPill,
                          ),
                        ),
                        child: Text(
                          '$stepIndex of $totalSteps',
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            color: AuthTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: AuthTheme.inputBorder, height: 1),

                // Options List
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemCount: options.length,
                  separatorBuilder: (context, _) => const Divider(
                    color: AuthTheme.inputBorder,
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  itemBuilder: (context, i) {
                    final opt = options[i];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => widget.onSubmit(opt),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 13,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(7),
                                  border: Border.all(
                                    color: AuthTheme.inputBorder,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      color: AuthTheme.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  opt,
                                  style: const TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    color: AuthTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AuthTheme.textSecondary,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const Divider(color: AuthTheme.inputBorder, height: 1),

                // "Something else" input
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Container(
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AuthTheme.radiusField,
                        ),
                        side: const BorderSide(
                          color: AuthTheme.inputBorder,
                          width: 1.0,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 2,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.edit_note_rounded,
                          color: AuthTheme.textSecondary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _otherCtrl,
                            onSubmitted: (_) => _submitCustom(),
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              color: AuthTheme.textPrimary,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Or type custom year / topic...',
                              hintStyle: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                color: Color(0xFF94A3B8),
                                fontSize: 13.5,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              isDense: true,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _submitCustom,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: AuthTheme.primary,
                            size: 18,
                          ),
                          tooltip: 'Submit',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
