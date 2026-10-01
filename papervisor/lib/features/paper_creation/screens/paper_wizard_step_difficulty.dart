import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  late final TextEditingController _easyController;
  late final TextEditingController _mediumController;
  late final TextEditingController _hardController;

  @override
  void initState() {
    super.initState();
    _easyPercentage = widget.state.easyPercentage.toDouble();
    _mediumPercentage = widget.state.mediumPercentage.toDouble();
    _hardPercentage = widget.state.hardPercentage.toDouble();

    _easyController = TextEditingController(text: '${_easyPercentage.round()}');
    _mediumController = TextEditingController(text: '${_mediumPercentage.round()}');
    _hardController = TextEditingController(text: '${_hardPercentage.round()}');
  }

  @override
  void dispose() {
    _easyController.dispose();
    _mediumController.dispose();
    _hardController.dispose();
    super.dispose();
  }

  int get _easyVal => int.tryParse(_easyController.text.trim()) ?? 0;
  int get _mediumVal => int.tryParse(_mediumController.text.trim()) ?? 0;
  int get _hardVal => int.tryParse(_hardController.text.trim()) ?? 0;

  int get _totalPercentage => _easyVal + _mediumVal + _hardVal;
  bool get _isExceeds100 => _totalPercentage > 100 || _easyVal > 100 || _mediumVal > 100 || _hardVal > 100;
  bool get _isExact100 => _totalPercentage == 100 && _easyVal <= 100 && _mediumVal <= 100 && _hardVal <= 100;
  bool get _isValid =>
      _isExact100 &&
      _easyVal >= 0 &&
      _mediumVal >= 0 &&
      _hardVal >= 0 &&
      _easyController.text.trim().isNotEmpty &&
      _mediumController.text.trim().isNotEmpty &&
      _hardController.text.trim().isNotEmpty;

  void _onDifficultySliderChanged(int changedIndex, double newVal) {
    newVal = newVal.clamp(0.0, 100.0);
    double easy = _easyPercentage.clamp(0.0, 100.0);
    double medium = _mediumPercentage.clamp(0.0, 100.0);
    double hard = _hardPercentage.clamp(0.0, 100.0);

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

    int roundedEasy = easy.round();
    int roundedMedium = medium.round();
    int roundedHard = (100 - roundedEasy - roundedMedium).clamp(0, 100);

    // Minor adjustment so integer sum equals 100 exactly
    if (roundedEasy + roundedMedium + roundedHard != 100) {
      if (changedIndex == 0) {
        roundedMedium = 100 - roundedEasy - roundedHard;
      } else {
        roundedEasy = 100 - roundedMedium - roundedHard;
      }
    }

    setState(() {
      _easyPercentage = roundedEasy.toDouble().clamp(0.0, 100.0);
      _mediumPercentage = roundedMedium.toDouble().clamp(0.0, 100.0);
      _hardPercentage = roundedHard.toDouble().clamp(0.0, 100.0);

      _easyController.text = '$roundedEasy';
      _mediumController.text = '$roundedMedium';
      _hardController.text = '$roundedHard';
    });
  }

  void _onTextFieldChanged(int changedIndex, String val) {
    final intVal = int.tryParse(val.trim()) ?? 0;
    final doubleVal = intVal.toDouble();

    // When text field is touched, the OTHER bars do NOT auto-increment or auto-decrement
    setState(() {
      if (changedIndex == 0) {
        _easyPercentage = doubleVal;
      } else if (changedIndex == 1) {
        _mediumPercentage = doubleVal;
      } else if (changedIndex == 2) {
        _hardPercentage = doubleVal;
      }
    });
  }

  void _applyPreset(double e, double m, double h) {
    setState(() {
      _easyPercentage = e;
      _mediumPercentage = m;
      _hardPercentage = h;
      _easyController.text = '${e.round()}';
      _mediumController.text = '${m.round()}';
      _hardController.text = '${h.round()}';
    });
  }

  void _saveDifficultyState() {
    widget.state.easyPercentage = _easyVal;
    widget.state.mediumPercentage = _mediumVal;
    widget.state.hardPercentage = _hardVal;

    if (_hardVal >= 50) {
      widget.state.difficulty = 'HARD';
    } else if (_easyVal >= 50) {
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              children: [
            // Top Step Header (No back arrow)
            WizardStepHeader(
              subjectName: widget.subject['name'] ?? 'Subject',
              currentStep: 4,
              title: 'Difficulty Level',
              subtitle: 'This difficulty level is applied section-wise. For example, if you have Very Short and Short Answer sections only, then Easy, Medium, and Hard will be applied to both the sections.',
              onBack: () => Navigator.pop(context),
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
                            controller: _easyController,
                            percentage: _easyPercentage,
                            color: const Color(0xFF059669),
                            bgColor: const Color(0xFFECFDF5),
                            borderColor: const Color(0xFFA7F3D0),
                            onSliderChanged: (v) => _onDifficultySliderChanged(0, v),
                            onTextChanged: (v) => _onTextFieldChanged(0, v),
                          ),
                          const SizedBox(height: 18),
                          _buildDifficultySliderRow(
                            title: 'Medium',
                            controller: _mediumController,
                            percentage: _mediumPercentage,
                            color: const Color(0xFFD97706),
                            bgColor: const Color(0xFFFFFBEB),
                            borderColor: const Color(0xFFFDE68A),
                            onSliderChanged: (v) => _onDifficultySliderChanged(1, v),
                            onTextChanged: (v) => _onTextFieldChanged(1, v),
                          ),
                          const SizedBox(height: 18),
                          _buildDifficultySliderRow(
                            title: 'Hard',
                            controller: _hardController,
                            percentage: _hardPercentage,
                            color: const Color(0xFFE11D48),
                            bgColor: const Color(0xFFFFF1F2),
                            borderColor: const Color(0xFFFECDD3),
                            onSliderChanged: (v) => _onDifficultySliderChanged(2, v),
                            onTextChanged: (v) => _onTextFieldChanged(2, v),
                          ),
                          const SizedBox(height: 18),
                          const Divider(color: Color(0xFFF1F5F9), height: 1),
                          const SizedBox(height: 14),
                          _buildTotalIndicator(),
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
                          isSelected: _easyVal == 50 && _mediumVal == 30 && _hardVal == 20,
                          onTap: () => _applyPreset(50, 30, 20),
                        ),
                        const SizedBox(width: 10),
                        _buildPresetButton(
                          label: 'Balanced',
                          breakdown: '25/50/25',
                          isSelected: _easyVal == 25 && _mediumVal == 50 && _hardVal == 25,
                          onTap: () => _applyPreset(25, 50, 25),
                        ),
                        const SizedBox(width: 10),
                        _buildPresetButton(
                          label: 'Challenging',
                          breakdown: '15/35/50',
                          isSelected: _easyVal == 15 && _mediumVal == 35 && _hardVal == 50,
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
              helperWidget: !_isValid
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECDD3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AuthTheme.error, size: 16),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _isExceeds100
                                  ? 'Difficulty percentages exceed 100% (Total: $_totalPercentage%)'
                                  : 'Total difficulty must equal 100% (currently $_totalPercentage%)',
                              style: const TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AuthTheme.error,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              onPressed: _isValid
                  ? () {
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

  Widget _buildTotalIndicator() {
    final isExact100 = _isValid;
    final isExceeds = _isExceeds100;
    final total = _totalPercentage;

    Color bg;
    Color border;
    Color fg;
    IconData icon;
    String text;

    if (isExact100) {
      bg = const Color(0xFFECFDF5);
      border = const Color(0xFFA7F3D0);
      fg = const Color(0xFF059669);
      icon = Icons.check_circle_rounded;
      text = 'Total: 100% (Balanced)';
    } else if (isExceeds) {
      bg = const Color(0xFFFFF1F2);
      border = const Color(0xFFFECDD3);
      fg = AuthTheme.error;
      icon = Icons.error_outline_rounded;
      text = 'Total: $total% (Exceeds 100% by ${total - 100}%)';
    } else {
      bg = const Color(0xFFFFFBEB);
      border = const Color(0xFFFDE68A);
      fg = const Color(0xFFD97706);
      icon = Icons.info_outline_rounded;
      text = 'Total: $total% (Needs +${100 - total}% to reach 100%)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, color: fg, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultySliderRow({
    required String title,
    required TextEditingController controller,
    required double percentage,
    required Color color,
    required Color bgColor,
    required Color borderColor,
    required ValueChanged<double> onSliderChanged,
    required ValueChanged<String> onTextChanged,
  }) {
    final val = int.tryParse(controller.text.trim()) ?? 0;
    final isInvalid = val > 100 || val < 0;

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
              width: 76,
              height: 34,
              decoration: BoxDecoration(
                color: isInvalid ? const Color(0xFFFFF1F2) : bgColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isInvalid ? AuthTheme.error : borderColor,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      textAlign: TextAlign.center,
                      onChanged: onTextChanged,
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isInvalid ? AuthTheme.error : color,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Text(
                    '%',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isInvalid ? AuthTheme.error : color,
                    ),
                  ),
                ],
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
            value: percentage.clamp(0.0, 100.0),
            min: 0,
            max: 100,
            onChanged: onSliderChanged,
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

