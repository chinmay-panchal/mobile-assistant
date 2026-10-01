import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../auth/theme/auth_theme.dart';
import '../models/paper_wizard_state.dart';
import '../widgets/wizard_bottom_bar.dart';
import '../widgets/wizard_step_header.dart';
import 'paper_wizard_step_reference.dart';

class PaperWizardStepMarks extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;

  const PaperWizardStepMarks({super.key, required this.subject, required this.state});

  @override
  State<PaperWizardStepMarks> createState() => _PaperWizardStepMarksState();
}

class _PaperWizardStepMarksState extends State<PaperWizardStepMarks> {
  late final TextEditingController _marksController;

  @override
  void initState() {
    super.initState();
    _marksController = TextEditingController(text: widget.state.totalMarks.toString());
  }

  @override
  void dispose() {
    _marksController.dispose();
    super.dispose();
  }

  int? get _parsedMarks => int.tryParse(_marksController.text.trim());
  bool get _isExceedsLimit => (_parsedMarks ?? 0) > 1000;

  bool get _isValid {
    final v = _parsedMarks;
    return v != null && v > 0 && v <= 1000;
  }

  static const List<int> _presets = [20, 40, 50, 60, 80, 100];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
          children: [
            // Top Step Header
            WizardStepHeader(
              subjectName: widget.subject['name'] ?? 'Subject',
              currentStep: 2,
              title: 'Total Marks',
              subtitle: 'Define the total marks for your examination paper',
              onBack: () => Navigator.pop(context),
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Input Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ENTER TOTAL MARKS (MAX 1000)',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: AuthTheme.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Text field for Marks
                          TextField(
                            controller: _marksController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(5),
                            ],
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AuthTheme.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. 80',
                              errorText: _isExceedsLimit ? 'Maximum marks limit is 1000' : null,
                              hintStyle: const TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                color: Color(0xFFCBD5E1),
                                fontWeight: FontWeight.w700,
                              ),
                              prefixIcon: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14),
                                child: Icon(
                                  Icons.assignment_turned_in_outlined,
                                  color: AuthTheme.primary,
                                  size: 26,
                                ),
                              ),
                              prefixIconConstraints: const BoxConstraints(minWidth: 50),
                              suffixText: 'Marks',
                              suffixStyle: const TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AuthTheme.textSecondary,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                                borderSide: const BorderSide(color: AuthTheme.primary, width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                                borderSide: const BorderSide(color: AuthTheme.error, width: 1.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AuthTheme.radiusField),
                                borderSide: const BorderSide(color: AuthTheme.error, width: 2.0),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Helper Note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE0E7FF)),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: AuthTheme.primary,
                                  size: 18,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'AI will automatically balance marks across sections and question difficulties.',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF3730A3),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Presets Section
                    const Text(
                      'QUICK PRESETS',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AuthTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _presets.map((v) {
                        final isSelected = _marksController.text == v.toString();
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => setState(() => _marksController.text = v.toString()),
                            borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AuthTheme.primary : Colors.white,
                                borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                                border: Border.all(
                                  color: isSelected ? AuthTheme.primary : const Color(0xFFCBD5E1),
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? AuthTheme.primary.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '$v',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: isSelected ? Colors.white : AuthTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Marks',
                                    style: TextStyle(
                                      fontFamily: AuthTheme.fontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.85)
                                          : AuthTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Continue Action Bar
            WizardBottomBar(
              text: 'Continue',
              onPressed: _isValid
                  ? () {
                      widget.state.totalMarks = int.parse(_marksController.text.trim());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaperWizardStepReference(
                            subject: widget.subject,
                            state: widget.state,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    ),
  ),
);
}
}
