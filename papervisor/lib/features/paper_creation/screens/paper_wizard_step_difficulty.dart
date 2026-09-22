import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../models/paper_wizard_state.dart';
import '../widgets/paper_meta_dialog.dart';
import '../widgets/wizard_bottom_bar.dart';
import '../widgets/wizard_step_header.dart';
import 'generating_loader_screen.dart';
import 'paper_wizard_step_format.dart';
export 'paper_wizard_step_format.dart';

// ─────────────────────────────────────────────────────────
// STEP 4: Difficulty Distribution
// ─────────────────────────────────────────────────────────

class PaperWizardStepDifficulty extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;
  const PaperWizardStepDifficulty({super.key, required this.subject, required this.state});

  @override
  State<PaperWizardStepDifficulty> createState() => _PaperWizardStepDifficultyState();
}

class _PaperWizardStepDifficultyState extends State<PaperWizardStepDifficulty> {
  double _easyPercentage = 25.0;
  double _mediumPercentage = 50.0;
  double _hardPercentage = 25.0;

  @override
  void initState() {
    super.initState();
    _easyPercentage = widget.state.easyPercentage.toDouble();
    _mediumPercentage = widget.state.mediumPercentage.toDouble();
    _hardPercentage = widget.state.hardPercentage.toDouble();
  }

  void _onDifficultySliderChanged(int changedIndex, double newVal) {
    newVal = newVal.clamp(0.0, 100.0);
    double easy = _easyPercentage;
    double medium = _mediumPercentage;
    double hard = _hardPercentage;

    if (changedIndex == 0) { // Easy changed
      easy = newVal;
      double remaining = 100.0 - easy;
      double sumOthers = medium + hard;
      if (sumOthers > 0) {
        medium = remaining * (medium / sumOthers);
        hard = remaining * (hard / sumOthers);
      } else {
        medium = remaining / 2.0;
        hard = remaining / 2.0;
      }
    } else if (changedIndex == 1) { // Medium changed
      medium = newVal;
      double remaining = 100.0 - medium;
      double sumOthers = easy + hard;
      if (sumOthers > 0) {
        easy = remaining * (easy / sumOthers);
        hard = remaining * (hard / sumOthers);
      } else {
        easy = remaining / 2.0;
        hard = remaining / 2.0;
      }
    } else if (changedIndex == 2) { // Hard changed
      hard = newVal;
      double remaining = 100.0 - hard;
      double sumOthers = easy + medium;
      if (sumOthers > 0) {
        easy = remaining * (easy / sumOthers);
        medium = remaining * (medium / sumOthers);
      } else {
        easy = remaining / 2.0;
        medium = remaining / 2.0;
      }
    }

    setState(() {
      _easyPercentage = easy.clamp(0.0, 100.0);
      _mediumPercentage = medium.clamp(0.0, 100.0);
      _hardPercentage = hard.clamp(0.0, 100.0);
    });
  }

  void _applyPreset(double e, double m, double h) {
    setState(() {
      _easyPercentage = e;
      _mediumPercentage = m;
      _hardPercentage = h;
    });
  }

  void _saveDifficultyState() {
    widget.state.easyPercentage = _easyPercentage.round();
    widget.state.mediumPercentage = _mediumPercentage.round();
    widget.state.hardPercentage = _hardPercentage.round();

    if (_hardPercentage >= 50) {
      widget.state.difficulty = 'HARD';
    } else if (_easyPercentage >= 50) {
      widget.state.difficulty = 'EASY';
    } else {
      widget.state.difficulty = 'MEDIUM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRef = widget.state.isReferenceMode;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top Step Header (No back arrow)
            WizardStepHeader(
              subjectName: widget.subject['name'] ?? 'Subject',
              currentStep: 4,
              title: 'Difficulty Level',
              subtitle: 'This difficulty level is applied section-wise. For example, if you have Very Short and Short Answer sections only, then Easy, Medium, and Hard will be applied to both the sections.',
            ),

            // Sliders & Presets Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Difficulty Card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                          _buildDifficultySliderRow(
                            title: 'Easy',
                            percentage: _easyPercentage,
                            color: const Color(0xFF059669),
                            bgColor: const Color(0xFFECFDF5),
                            borderColor: const Color(0xFFA7F3D0),
                            onChanged: (v) => _onDifficultySliderChanged(0, v),
                          ),
                          const SizedBox(height: 18),
                          _buildDifficultySliderRow(
                            title: 'Medium',
                            percentage: _mediumPercentage,
                            color: const Color(0xFFD97706),
                            bgColor: const Color(0xFFFFFBEB),
                            borderColor: const Color(0xFFFDE68A),
                            onChanged: (v) => _onDifficultySliderChanged(1, v),
                          ),
                          const SizedBox(height: 18),
                          _buildDifficultySliderRow(
                            title: 'Hard',
                            percentage: _hardPercentage,
                            color: const Color(0xFFE11D48),
                            bgColor: const Color(0xFFFFF1F2),
                            borderColor: const Color(0xFFFECDD3),
                            onChanged: (v) => _onDifficultySliderChanged(2, v),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Presets
                    const Text(
                      'PRESETS',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                        color: AuthTheme.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _buildPresetButton(
                          label: 'Beginner',
                          breakdown: '50/30/20',
                          isSelected: _easyPercentage == 50 && _mediumPercentage == 30 && _hardPercentage == 20,
                          onTap: () => _applyPreset(50, 30, 20),
                        ),
                        const SizedBox(width: 10),
                        _buildPresetButton(
                          label: 'Balanced',
                          breakdown: '25/50/25',
                          isSelected: _easyPercentage == 25 && _mediumPercentage == 50 && _hardPercentage == 25,
                          onTap: () => _applyPreset(25, 50, 25),
                        ),
                        const SizedBox(width: 10),
                        _buildPresetButton(
                          label: 'Challenging',
                          breakdown: '15/35/50',
                          isSelected: _easyPercentage == 15 && _mediumPercentage == 35 && _hardPercentage == 50,
                          onTap: () => _applyPreset(15, 35, 50),
                        ),
                      ],
                    ),

                    if (isRef) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded, color: Color(0xFF2563EB), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Reference blueprint active: Section layout and question counts will match the chosen reference paper.',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1E40AF),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Action Bar
            WizardBottomBar(
              text: isRef ? 'Generate Paper' : 'Continue',
              icon: isRef ? Icons.auto_awesome_rounded : Icons.arrow_forward_rounded,
              onPressed: () {
                _saveDifficultyState();
                if (isRef) {
                  PaperMetaDialog.show(
                    context: context,
                    initialMinutes: widget.state.timeAllowedMinutes,
                    initialClass: widget.state.className,
                    onGenerate: (title, className, minutes) {
                      widget.state.className = className;
                      widget.state.timeAllowedMinutes = minutes;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GeneratingLoaderScreen(
                            subject: widget.subject,
                            state: widget.state,
                            title: title,
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaperWizardStepFormat(
                        subject: widget.subject,
                        state: widget.state,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySliderRow({
    required String title,
    required double percentage,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                '${percentage.round()}%',
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: const Color(0xFFF1F5F9),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.15),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: percentage,
            min: 0,
            max: 100,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton({
    required String label,
    required String breakdown,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AuthTheme.primary : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AuthTheme.primary : const Color(0xFFE2E8F0),
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
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AuthTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  breakdown,
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AuthTheme.textSecondary,
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
