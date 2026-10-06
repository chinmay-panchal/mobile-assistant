import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../models/paper_wizard_state.dart';
import '../widgets/wizard_bottom_bar.dart';
import '../widgets/wizard_step_header.dart';
import 'paper_wizard_step_reference.dart';

class PaperWizardStepMarks extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;

  const PaperWizardStepMarks({
    super.key,
    required this.subject,
    required this.state,
  });

  @override
  State<PaperWizardStepMarks> createState() => _PaperWizardStepMarksState();
}

class _PaperWizardStepMarksState extends State<PaperWizardStepMarks> {
  late final TextEditingController _marksController;

  @override
  void initState() {
    super.initState();
    _marksController = TextEditingController(
      text: widget.state.totalMarks.toString(),
    );
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
    Provider.of<ThemeProvider?>(context, listen: true);

    return Scaffold(
      backgroundColor: WorkspaceTheme.canvas,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
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
                    subtitle:
                        'Define the total marks for your examination paper',
                    onBack: () => Navigator.pop(context),
                  ),

                  // Main Content Area
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: WorkspaceTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: WorkspaceTheme.borderSubtle,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: WorkspaceTheme.isDark ? 0.3 : 0.025,
                                  ),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ENTER TOTAL MARKS (MAX 1000)',
                                  style: TextStyle(
                                    fontFamily: WorkspaceTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.1,
                                    color: WorkspaceTheme.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // Text field for Marks
                                TextField(
                                  controller: _marksController,
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) =>
                                      FocusScope.of(context).unfocus(),
                                  onEditingComplete: () =>
                                      FocusScope.of(context).unfocus(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  style: TextStyle(
                                    fontFamily: WorkspaceTheme.fontFamily,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: WorkspaceTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'e.g. 80',
                                    errorText: _isExceedsLimit
                                        ? 'Maximum marks limit is 1000'
                                        : null,
                                    hintStyle: TextStyle(
                                      fontFamily: WorkspaceTheme.fontFamily,
                                      color: WorkspaceTheme.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                      ),
                                      child: Icon(
                                        Icons.assignment_turned_in_outlined,
                                        color: WorkspaceTheme.primaryDark,
                                        size: 26,
                                      ),
                                    ),
                                    prefixIconConstraints: const BoxConstraints(
                                      minWidth: 50,
                                    ),
                                    suffixText: 'Marks',
                                    suffixStyle: TextStyle(
                                      fontFamily: WorkspaceTheme.fontFamily,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: WorkspaceTheme.textSecondary,
                                    ),
                                    filled: true,
                                    fillColor: WorkspaceTheme.surfaceMuted,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        WorkspaceTheme.radiusCard,
                                      ),
                                      borderSide: BorderSide(
                                        color: WorkspaceTheme.borderSubtle,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        WorkspaceTheme.radiusCard,
                                      ),
                                      borderSide: BorderSide(
                                        color: WorkspaceTheme.borderSubtle,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        WorkspaceTheme.radiusCard,
                                      ),
                                      borderSide: BorderSide(
                                        color: WorkspaceTheme.isDark
                                            ? const Color(0xFF38BDF8)
                                            : WorkspaceTheme.primaryDark,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        WorkspaceTheme.radiusCard,
                                      ),
                                      borderSide: const BorderSide(
                                        color: WorkspaceTheme.error,
                                        width: 1.0,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        WorkspaceTheme.radiusCard,
                                      ),
                                      borderSide: const BorderSide(
                                        color: WorkspaceTheme.error,
                                        width: 2.0,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),

                                // Helper Note
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: WorkspaceTheme.isDark
                                        ? const Color(0xFF1E293B)
                                        : const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: WorkspaceTheme.isDark
                                          ? const Color(0xFF334155)
                                          : const Color(0xFFE0E7FF),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        color: WorkspaceTheme.primaryDark,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          'AI will automatically balance marks across sections and question difficulties.',
                                          style: TextStyle(
                                            fontFamily:
                                                WorkspaceTheme.fontFamily,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: WorkspaceTheme.isDark
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF3730A3),
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
                          Text(
                            'QUICK PRESETS',
                            style: TextStyle(
                              fontFamily: WorkspaceTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.1,
                              color: WorkspaceTheme.textTertiary,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _presets.map((v) {
                              final isSelected =
                                  _marksController.text == v.toString();
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    FocusScope.of(context).unfocus();
                                    setState(
                                      () =>
                                          _marksController.text = v.toString(),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(
                                    WorkspaceTheme.radiusPill,
                                  ),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 22,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? WorkspaceTheme.primaryDark
                                          : WorkspaceTheme.surfaceWhite,
                                      borderRadius: BorderRadius.circular(
                                        WorkspaceTheme.radiusPill,
                                      ),
                                      border: Border.all(
                                        color: isSelected
                                            ? WorkspaceTheme.primaryDark
                                            : WorkspaceTheme.borderSubtle,
                                        width: isSelected ? 1.5 : 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isSelected
                                              ? WorkspaceTheme.primaryDark
                                                    .withValues(alpha: 0.2)
                                              : Colors.black.withValues(
                                                  alpha: 0.02,
                                                ),
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
                                            fontFamily:
                                                WorkspaceTheme.fontFamily,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? Colors.white
                                                : WorkspaceTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Marks',
                                          style: TextStyle(
                                            fontFamily:
                                                WorkspaceTheme.fontFamily,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? Colors.white.withValues(
                                                    alpha: 0.85,
                                                  )
                                                : WorkspaceTheme.textSecondary,
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
                            widget.state.totalMarks = int.parse(
                              _marksController.text.trim(),
                            );
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
      ),
    );
  }
}
