import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../models/paper_wizard_state.dart';
import 'generating_loader_screen.dart';

// ─────────────────────────────────────────────────────────
// STEP 5: Format  (CUSTOM mode only)
// ─────────────────────────────────────────────────────────

class PaperWizardStepFormat extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;
  const PaperWizardStepFormat({Key? key, required this.subject, required this.state}) : super(key: key);

  @override
  State<PaperWizardStepFormat> createState() => _PaperWizardStepFormatState();
}

class _PaperWizardStepFormatState extends State<PaperWizardStepFormat> {
  int _selectedFormat = 0; // 0=none, 1=MCQ, 2=QuestionsOnly, 3=Hybrid

  // MCQ Only
  int _mcqMarksEach = 1;
  int get _mcqQuestions => widget.state.totalMarks ~/ _mcqMarksEach;
  int get _mcqRemainder => widget.state.totalMarks % _mcqMarksEach;

  // Questions Only
  int _veryShortQ = 0;
  int _veryShortMarks = 1;
  int _shortQ = 0;
  int _shortMarks = 3;
  int _longQ = 0;
  int _longMarks = 5;

  // Hybrid
  int _hybridMcqQ = 0;
  int _hybridMcqMarks = 1;
  int _hybridVeryShortQ = 0;
  int _hybridVeryShortMarks = 1;
  int _hybridShortQ = 0;
  int _hybridShortMarks = 3;
  int _hybridLongQ = 0;
  int _hybridLongMarks = 5;

  // Shared Format Options
  bool _hasAlternativeQuestions = false;
  bool _enableNumericalQuestions = false;
  double _numericalPercentage = 20.0;

  @override
  void initState() {
    super.initState();
    _enableNumericalQuestions = widget.state.enableNumericalPercentage;
    if (widget.state.numericalPercentage > 0) {
      _numericalPercentage = widget.state.numericalPercentage.toDouble();
    }

    // Questions Only Defaults
    _veryShortMarks = 1;
    _shortMarks = 3;
    _longMarks = 5;

    _longQ = (widget.state.totalMarks * 0.4) ~/ _longMarks;
    _shortQ = (widget.state.totalMarks * 0.4) ~/ _shortMarks;
    _veryShortQ = (widget.state.totalMarks - (_longQ * _longMarks) - (_shortQ * _shortMarks)) ~/ _veryShortMarks;
    if (_veryShortQ < 0) _veryShortQ = 0;

    // Hybrid Defaults
    _hybridMcqMarks = 1;
    _hybridVeryShortMarks = 1;
    _hybridShortMarks = 3;
    _hybridLongMarks = 5;

    _hybridLongQ = (widget.state.totalMarks * 0.3) ~/ _hybridLongMarks;
    _hybridShortQ = (widget.state.totalMarks * 0.3) ~/ _hybridShortMarks;
    _hybridMcqQ = (widget.state.totalMarks * 0.4) ~/ _hybridMcqMarks;
    _hybridVeryShortQ = (widget.state.totalMarks - (_hybridLongQ * _hybridLongMarks) - (_hybridShortQ * _hybridShortMarks) - (_hybridMcqQ * _hybridMcqMarks)) ~/ _hybridVeryShortMarks;
    if (_hybridVeryShortQ < 0) _hybridVeryShortQ = 0;
  }

  int get _questionsOnlyTotalMarks => (_veryShortQ * _veryShortMarks) + (_shortQ * _shortMarks) + (_longQ * _longMarks);
  bool get _isQuestionsOnlyValid => _questionsOnlyTotalMarks == widget.state.totalMarks;

  int get _hybridTotalMarks => (_hybridMcqQ * _hybridMcqMarks) + (_hybridVeryShortQ * _hybridVeryShortMarks) + (_hybridShortQ * _hybridShortMarks) + (_hybridLongQ * _hybridLongMarks);
  bool get _isHybridValid => _hybridTotalMarks == widget.state.totalMarks;

  bool get _canGenerate {
    if (_selectedFormat == 0) return false;
    if (_selectedFormat == 1 && _mcqRemainder != 0) return false;
    if (_selectedFormat == 2 && !_isQuestionsOnlyValid) return false;
    if (_selectedFormat == 3 && !_isHybridValid) return false;
    return true;
  }

  List<Map<String, dynamic>> _buildQuestionConfigs() {
    final altCount = _hasAlternativeQuestions ? 2 : 1;
    switch (_selectedFormat) {
      case 1:
        return [{
          'question_type': 'MCQ',
          'question_count': _mcqQuestions,
          'marks_per_question': _mcqMarksEach,
          'section_name': 'Section A',
          'has_internal_choice': _hasAlternativeQuestions,
          'alternatives_per_question': altCount,
        }];
      case 2:
        final configs = <Map<String, dynamic>>[];
        if (_veryShortQ > 0) configs.add({'question_type': 'VERY_SHORT_ANSWER', 'question_count': _veryShortQ, 'marks_per_question': _veryShortMarks, 'section_name': 'Section A', 'has_internal_choice': _hasAlternativeQuestions, 'alternatives_per_question': altCount});
        if (_shortQ > 0) configs.add({'question_type': 'SHORT_ANSWER', 'question_count': _shortQ, 'marks_per_question': _shortMarks, 'section_name': 'Section B', 'has_internal_choice': _hasAlternativeQuestions, 'alternatives_per_question': altCount});
        if (_longQ > 0) configs.add({'question_type': 'LONG_ANSWER', 'question_count': _longQ, 'marks_per_question': _longMarks, 'section_name': 'Section C', 'has_internal_choice': _hasAlternativeQuestions, 'alternatives_per_question': altCount});
        return configs;
      case 3:
        final configs = <Map<String, dynamic>>[];
        if (_hybridMcqQ > 0) configs.add({'question_type': 'MCQ', 'question_count': _hybridMcqQ, 'marks_per_question': _hybridMcqMarks, 'section_name': 'Section A', 'has_internal_choice': false, 'alternatives_per_question': altCount});
        if (_hybridVeryShortQ > 0) configs.add({'question_type': 'VERY_SHORT_ANSWER', 'question_count': _hybridVeryShortQ, 'marks_per_question': _hybridVeryShortMarks, 'section_name': 'Section B', 'has_internal_choice': _hasAlternativeQuestions, 'alternatives_per_question': altCount});
        if (_hybridShortQ > 0) configs.add({'question_type': 'SHORT_ANSWER', 'question_count': _hybridShortQ, 'marks_per_question': _hybridShortMarks, 'section_name': 'Section C', 'has_internal_choice': _hasAlternativeQuestions, 'alternatives_per_question': altCount});
        if (_hybridLongQ > 0) configs.add({'question_type': 'LONG_ANSWER', 'question_count': _hybridLongQ, 'marks_per_question': _hybridLongMarks, 'section_name': 'Section D', 'has_internal_choice': _hasAlternativeQuestions, 'alternatives_per_question': altCount});
        return configs;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Step 5 of 5', style: theme.textTheme.bodySmall),
          Text('Format', style: theme.textTheme.titleLarge),
        ]),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(children: List.generate(5, (i) => Expanded(child: Container(
              margin: EdgeInsets.only(right: i == 4 ? 0 : 8), height: 4,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
            )))),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('PAPER STRUCTURE', style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                _buildCard(index: 1, icon: Icons.grid_view, iconColor: AppColors.primary, title: 'MCQ Only', subtitle: 'Multiple choice with 4 options', expandedContent: _mcqExpanded()),
                _buildCard(index: 2, icon: Icons.format_list_bulleted, iconColor: AppColors.success, title: 'Questions Only', subtitle: 'Short and long answer questions', expandedContent: _questionsOnlyExpanded()),
                _buildCard(index: 3, icon: Icons.dashboard_customize, iconColor: const Color(0xFF9333EA), title: 'Hybrid Mix', subtitle: 'MCQ combined with written questions', expandedContent: _hybridExpanded()),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              text: 'Generate Paper',
              icon: const Icon(Icons.auto_awesome, color: Colors.white),
              onPressed: _canGenerate ? () => _showTitleDialog(context) : null,
            ),
          ),
        ]),
      ),
    );
  }

  void _showTitleDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final classCtrl = TextEditingController();
    final minutesCtrl = TextEditingController(text: widget.state.timeAllowedMinutes.toString());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_document, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Name your paper',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Give your new exam paper a title.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Paper Title
              TextField(
                controller: ctrl,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g. Mid-Term Exam 2025',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              // Academic Level + Duration row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: classCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Academic Level',
                        hintText: 'e.g. Class 8',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: minutesCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Minutes',
                        hintText: '180',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final title = ctrl.text.trim();
                        if (title.isEmpty) return;
                        // Save extra fields to state
                        widget.state.className = classCtrl.text.trim();
                        widget.state.timeAllowedMinutes =
                            int.tryParse(minutesCtrl.text.trim()) ?? 180;
                        widget.state.enableNumericalPercentage = _enableNumericalQuestions;
                        widget.state.numericalPercentage = _enableNumericalQuestions ? _numericalPercentage.round() : 0;
                        Navigator.pop(ctx);
                        widget.state.questionConfigs = _buildQuestionConfigs();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => GeneratingLoaderScreen(subject: widget.subject, state: widget.state, title: title),
                        ));
                      },
                      child: const Text('Generate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required int index, required IconData icon, required Color iconColor, required String title, required String subtitle, required Widget expandedContent}) {
    final isSelected = _selectedFormat == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = isSelected ? 0 : index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? iconColor : AppColors.divider, width: isSelected ? 2 : 1),
        ),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              CircleAvatar(backgroundColor: iconColor.withOpacity(0.1), child: Icon(icon, color: iconColor, size: 20)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ])),
              if (isSelected) Icon(Icons.check_circle_outline, color: iconColor) else const Icon(Icons.expand_more, color: AppColors.textTertiary),
            ]),
          ),
          if (isSelected) Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: expandedContent),
        ]),
      ),
    );
  }

  Widget _mcqExpanded() => Column(children: [
    const Divider(color: AppColors.divider),
    const SizedBox(height: 12),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('QUESTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.0)),
          const SizedBox(height: 8),
          Container(
            height: 28,
            alignment: Alignment.centerLeft,
            child: Text(
              '$_mcqQuestions',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
          ),
        ]),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        const Text('MARKS EACH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.0)),
        const SizedBox(height: 8),
        _stepper(_mcqMarksEach, () { if (_mcqMarksEach > 1) setState(() => _mcqMarksEach--); }, () => setState(() => _mcqMarksEach++)),
      ]),
    ]),
    if (_mcqRemainder != 0) ...[
      const SizedBox(height: 12),
      Text('Total marks (${widget.state.totalMarks}) not divisible by $_mcqMarksEach', style: const TextStyle(color: AppColors.error, fontSize: 12)),
    ],
    _buildExtraFormatOptions(AppColors.primary),
  ]);

  Widget _questionsOnlyExpanded() {
    final diff = widget.state.totalMarks - _questionsOnlyTotalMarks;
    return Column(children: [
      const Divider(color: AppColors.divider),
      const SizedBox(height: 12),
      _qRowWithMarks(
        label: 'Very Short',
        marksValue: _veryShortMarks,
        onMarksDec: () { if (_veryShortMarks > 1) setState(() => _veryShortMarks--); },
        onMarksInc: () => setState(() => _veryShortMarks++),
        countValue: _veryShortQ,
        onCountDec: () { if (_veryShortQ > 0) setState(() => _veryShortQ--); },
        onCountInc: () => setState(() => _veryShortQ++),
      ),
      const SizedBox(height: 12),
      _qRowWithMarks(
        label: 'Short',
        marksValue: _shortMarks,
        onMarksDec: () { if (_shortMarks > 1) setState(() => _shortMarks--); },
        onMarksInc: () => setState(() => _shortMarks++),
        countValue: _shortQ,
        onCountDec: () { if (_shortQ > 0) setState(() => _shortQ--); },
        onCountInc: () => setState(() => _shortQ++),
      ),
      const SizedBox(height: 12),
      _qRowWithMarks(
        label: 'Long',
        marksValue: _longMarks,
        onMarksDec: () { if (_longMarks > 1) setState(() => _longMarks--); },
        onMarksInc: () => setState(() => _longMarks++),
        countValue: _longQ,
        onCountDec: () { if (_longQ > 0) setState(() => _longQ--); },
        onCountInc: () => setState(() => _longQ++),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isQuestionsOnlyValid ? AppColors.successLight : AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Marks Used:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('$_questionsOnlyTotalMarks / ${widget.state.totalMarks}', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isQuestionsOnlyValid ? AppColors.success : AppColors.error,
          )),
        ]),
      ),
      if (diff != 0) Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(diff > 0 ? 'Add $diff more marks' : 'Remove ${diff.abs()} marks', style: const TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      _buildExtraFormatOptions(AppColors.success),
    ]);
  }

  Widget _hybridExpanded() {
    final diff = widget.state.totalMarks - _hybridTotalMarks;
    return Column(children: [
      const Divider(color: AppColors.divider),
      const SizedBox(height: 12),
      _qRowWithMarks(
        label: 'MCQ',
        marksValue: _hybridMcqMarks,
        onMarksDec: () { if (_hybridMcqMarks > 1) setState(() => _hybridMcqMarks--); },
        onMarksInc: () => setState(() => _hybridMcqMarks++),
        countValue: _hybridMcqQ,
        onCountDec: () { if (_hybridMcqQ > 0) setState(() => _hybridMcqQ--); },
        onCountInc: () => setState(() => _hybridMcqQ++),
      ),
      const SizedBox(height: 12),
      _qRowWithMarks(
        label: 'Very Short',
        marksValue: _hybridVeryShortMarks,
        onMarksDec: () { if (_hybridVeryShortMarks > 1) setState(() => _hybridVeryShortMarks--); },
        onMarksInc: () => setState(() => _hybridVeryShortMarks++),
        countValue: _hybridVeryShortQ,
        onCountDec: () { if (_hybridVeryShortQ > 0) setState(() => _hybridVeryShortQ--); },
        onCountInc: () => setState(() => _hybridVeryShortQ++),
      ),
      const SizedBox(height: 12),
      _qRowWithMarks(
        label: 'Short',
        marksValue: _hybridShortMarks,
        onMarksDec: () { if (_hybridShortMarks > 1) setState(() => _hybridShortMarks--); },
        onMarksInc: () => setState(() => _hybridShortMarks++),
        countValue: _hybridShortQ,
        onCountDec: () { if (_hybridShortQ > 0) setState(() => _hybridShortQ--); },
        onCountInc: () => setState(() => _hybridShortQ++),
      ),
      const SizedBox(height: 12),
      _qRowWithMarks(
        label: 'Long',
        marksValue: _hybridLongMarks,
        onMarksDec: () { if (_hybridLongMarks > 1) setState(() => _hybridLongMarks--); },
        onMarksInc: () => setState(() => _hybridLongMarks++),
        countValue: _hybridLongQ,
        onCountDec: () { if (_hybridLongQ > 0) setState(() => _hybridLongQ--); },
        onCountInc: () => setState(() => _hybridLongQ++),
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _isHybridValid ? AppColors.successLight : AppColors.errorLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Total Marks Used:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text('$_hybridTotalMarks / ${widget.state.totalMarks}', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isHybridValid ? AppColors.success : AppColors.error,
          )),
        ]),
      ),
      if (diff != 0) Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Text(diff > 0 ? 'Add $diff more marks' : 'Remove ${diff.abs()} marks', style: const TextStyle(color: AppColors.error, fontSize: 12)),
      ),
      _buildExtraFormatOptions(const Color(0xFF9333EA)),
    ]);
  }

  Widget _buildExtraFormatOptions(Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Divider(color: AppColors.divider),
        const SizedBox(height: 12),
        // 1. Alternative Questions Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Alternative (OR) Questions',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Include internal choice alternatives',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(
              value: _hasAlternativeQuestions,
              activeColor: accentColor,
              onChanged: (val) => setState(() => _hasAlternativeQuestions = val),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // 2. Numerical Questions Toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Numerical Questions',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Include numerical problem questions',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Switch(
              value: _enableNumericalQuestions,
              activeColor: accentColor,
              onChanged: (val) => setState(() {
                _enableNumericalQuestions = val;
                if (val && _numericalPercentage == 0) {
                  _numericalPercentage = 20.0;
                }
              }),
            ),
          ],
        ),
        if (_enableNumericalQuestions) ...[
          const SizedBox(height: 12),
          // Numerical Percentage Slider (Matching Card Accent Color)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Numericals Percentage',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_numericalPercentage.round()}%',
                      style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: accentColor,
                  inactiveTrackColor: accentColor.withOpacity(0.2),
                  thumbColor: accentColor,
                  overlayColor: accentColor.withOpacity(0.15),
                  valueIndicatorColor: accentColor,
                  valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                child: Slider(
                  value: _numericalPercentage,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${_numericalPercentage.round()}%',
                  onChanged: (val) => setState(() => _numericalPercentage = val),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _qRowWithMarks({
    required String label,
    required int marksValue,
    required VoidCallback onMarksDec,
    required VoidCallback onMarksInc,
    required int countValue,
    required VoidCallback onCountDec,
    required VoidCallback onCountInc,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('MARKS EACH', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                _miniStepper(marksValue, onMarksDec, onMarksInc),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('QTY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                _miniStepper(countValue, onCountDec, onCountInc),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _miniStepper(int value, VoidCallback onDec, VoidCallback onInc) => Row(
    children: [
      _stepBtn('-', onDec),
      const SizedBox(width: 6),
      SizedBox(
        width: 20,
        child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ),
      const SizedBox(width: 6),
      _stepBtn('+', onInc),
    ],
  );

  Widget _stepper(int value, VoidCallback onDec, VoidCallback onInc) => Row(children: [
    _stepBtn('-', onDec), const SizedBox(width: 12),
    SizedBox(width: 24, child: Text('$value', textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
    const SizedBox(width: 12), _stepBtn('+', onInc),
  ]);

  Widget _stepBtn(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.divider)),
      alignment: Alignment.center,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
    ),
  );

  Widget _qRow(String label, int value, VoidCallback onDec, VoidCallback onInc) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)), _stepper(value, onDec, onInc)],
  );
}

// ─────────────────────────────────────────────────────────
// STEP 4: Difficulty
// ─────────────────────────────────────────────────────────

class PaperWizardStepDifficulty extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;
  const PaperWizardStepDifficulty({Key? key, required this.subject, required this.state}) : super(key: key);

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
      _easyPercentage = easy;
      _mediumPercentage = medium;
      _hardPercentage = hard;
    });
  }

  Widget _buildDifficultySlider({
    required String label,
    required double value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    final roundedVal = value.round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$roundedVal%',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.15),
            valueIndicatorColor: color,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            divisions: 100,
            label: '$roundedVal%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _saveDifficultyState() {
    int roundedEasy = _easyPercentage.round();
    int roundedMedium = _mediumPercentage.round();
    int roundedHard = 100 - (roundedEasy + roundedMedium);
    if (roundedHard < 0) {
      roundedHard = 0;
      roundedMedium = 100 - roundedEasy;
    }
    widget.state.easyPercentage = roundedEasy;
    widget.state.mediumPercentage = roundedMedium;
    widget.state.hardPercentage = roundedHard;

    if (roundedEasy >= 60) {
      widget.state.difficulty = 'EASY';
    } else if (roundedHard >= 60) {
      widget.state.difficulty = 'HARD';
    } else {
      widget.state.difficulty = 'MEDIUM';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRef = widget.state.isReferenceMode;

    final easyInt = _easyPercentage.round();
    final mediumInt = _mediumPercentage.round();
    final hardInt = (100 - easyInt - mediumInt).clamp(0, 100);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Step 4 of ${isRef ? 4 : 5}', style: theme.textTheme.bodySmall),
          Text('Difficulty Breakdown', style: theme.textTheme.titleLarge),
        ]),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(children: List.generate(5, (i) => Expanded(child: Container(
              margin: EdgeInsets.only(right: i == 4 ? 0 : 8), height: 4,
              decoration: BoxDecoration(
                color: isRef
                    ? (i <= 3 ? AppColors.primary : AppColors.divider)
                    : (i <= 3 ? AppColors.primary : AppColors.divider),
                borderRadius: BorderRadius.circular(2),
              ),
            )))),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('DIFFICULTY RATIO (TOTAL 100%)', style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2)),
                const SizedBox(height: 16),
                
                // Horizontal proportion visual bar
                Container(
                  height: 14,
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    color: AppColors.divider,
                  ),
                  child: Row(
                    children: [
                      if (_easyPercentage > 0)
                        Expanded(
                          flex: (_easyPercentage * 10).round().clamp(1, 1000),
                          child: Container(color: AppColors.success),
                        ),
                      if (_mediumPercentage > 0)
                        Expanded(
                          flex: (_mediumPercentage * 10).round().clamp(1, 1000),
                          child: Container(color: AppColors.warning),
                        ),
                      if (_hardPercentage > 0)
                        Expanded(
                          flex: (_hardPercentage * 10).round().clamp(1, 1000),
                          child: Container(color: AppColors.error),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                _buildDifficultySlider(
                  label: 'Easy Questions',
                  value: _easyPercentage,
                  color: AppColors.success,
                  onChanged: (val) => _onDifficultySliderChanged(0, val),
                ),
                const SizedBox(height: 12),
                _buildDifficultySlider(
                  label: 'Medium Questions',
                  value: _mediumPercentage,
                  color: AppColors.warning,
                  onChanged: (val) => _onDifficultySliderChanged(1, val),
                ),
                const SizedBox(height: 12),
                _buildDifficultySlider(
                  label: 'Hard Questions',
                  value: _hardPercentage,
                  color: AppColors.error,
                  onChanged: (val) => _onDifficultySliderChanged(2, val),
                ),

                const SizedBox(height: 24),

                // Info summary card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryLight.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.analytics_outlined, color: AppColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Paper will feature $easyInt% Easy, $mediumInt% Medium, and $hardInt% Hard questions.',
                          style: const TextStyle(color: AppColors.primaryDark, fontSize: 13, fontWeight: FontWeight.w500, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),

                if (isRef) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(0.08), borderRadius: BorderRadius.circular(14)),
                    child: Row(children: const [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 18), SizedBox(width: 10),
                      Expanded(child: Text('Format will be inferred from your reference paper — no manual setup needed.', style: TextStyle(color: AppColors.primary, fontSize: 13))),
                    ]),
                  ),
                ],
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: PrimaryButton(
              text: isRef ? 'Generate Paper' : 'Continue',
              icon: Icon(isRef ? Icons.auto_awesome : Icons.arrow_forward, color: Colors.white),
              onPressed: () {
                _saveDifficultyState();
                if (isRef) {
                  _showTitleDialog(context);
                } else {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => PaperWizardStepFormat(subject: widget.subject, state: widget.state),
                  ));
                }
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _showTitleDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final classCtrl = TextEditingController();
    final minutesCtrl = TextEditingController(text: widget.state.timeAllowedMinutes.toString());
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit_document, color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: 20),
              const Text(
                'Name your paper',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Give your new exam paper a title.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Paper Title
              TextField(
                controller: ctrl,
                autofocus: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'e.g. Board Practice 2025',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              // Academic Level + Duration row
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: classCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Academic Level',
                        hintText: 'e.g. Class 8',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: minutesCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Minutes',
                        hintText: '180',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        filled: false,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.divider)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
                        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {
                        final title = ctrl.text.trim();
                        if (title.isEmpty) return;
                        // Save extra fields to state
                        widget.state.className = classCtrl.text.trim();
                        widget.state.timeAllowedMinutes =
                            int.tryParse(minutesCtrl.text.trim()) ?? 180;
                        Navigator.pop(ctx);
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => GeneratingLoaderScreen(subject: widget.subject, state: widget.state, title: title),
                        ));
                      },
                      child: const Text('Generate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
