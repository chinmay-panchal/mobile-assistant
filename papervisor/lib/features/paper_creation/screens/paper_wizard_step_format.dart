import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_text_field.dart';
import '../models/paper_wizard_state.dart';
import '../widgets/wizard_bottom_bar.dart';
import '../widgets/wizard_step_header.dart';
import '../widgets/alternative_type_selector.dart';
import 'generating_loader_screen.dart';

/// STEP 5: Format, Section Layout & Exam Details (Custom mode).
///
/// Features a streamlined, uncluttered two-stage flow:
/// - Stage 0: Layout Pattern Selection & Section Marks Balancing
/// - Stage 1: Exam Metadata (Title, Class, Time) & Advanced Format Options
class PaperWizardStepFormat extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;

  const PaperWizardStepFormat({
    super.key,
    required this.subject,
    required this.state,
  });

  @override
  State<PaperWizardStepFormat> createState() => _PaperWizardStepFormatState();
}

class _PaperWizardStepFormatState extends State<PaperWizardStepFormat> {
  // Stage: 0 = Question Format & Section Distribution, 1 = Exam Details & Generate
  int _currentStage = 0;

  // Selected layout pattern: 1 = MCQ Only, 2 = Subjective Only, 3 = Hybrid
  int _selectedFormat = 1;

  // ── Format 1: MCQ Only ─────────────────────────────
  int _mcqMarksEach = 1;
  int get _mcqQuestions => widget.state.totalMarks ~/ _mcqMarksEach;
  int get _mcqRemainder => widget.state.totalMarks % _mcqMarksEach;

  // ── Format 2: Subjective Questions Only ────────────
  int _veryShortQ = 0;
  int _veryShortMarks = 1;
  int _shortQ = 0;
  int _shortMarks = 3;
  int _longQ = 0;
  int _longMarks = 5;

  // ── Format 3: Comprehensive Hybrid ─────────────────
  int _hybridMcqQ = 0;
  int _hybridMcqMarks = 1;
  int _hybridVeryShortQ = 0;
  int _hybridVeryShortMarks = 1;
  int _hybridShortQ = 0;
  int _hybridShortMarks = 3;
  int _hybridLongQ = 0;
  int _hybridLongMarks = 5;

  // ── Stage 1 Options ────────────────────────────────
  late TextEditingController _titleController;
  late TextEditingController _classController;
  late TextEditingController _minutesController;
  int _selectedMinutes = 90;
  bool _hasAlternativeQuestions = false;
  int _alternativeType =
      1; // 1 = Simple OR, 2 = Attempt X of Y, 3 = Either/Or Section
  List<String> _selectedAlternativeSections = [];
  Map<String, int> _attemptQuestionCounts = {};
  bool _enableNumericalQuestions = false;
  double _numericalPercentage = 20.0;

  @override
  void initState() {
    super.initState();
    _enableNumericalQuestions = widget.state.enableNumericalPercentage;
    if (widget.state.numericalPercentage > 0) {
      _numericalPercentage = widget.state.numericalPercentage.toDouble();
    }

    _selectedMinutes = widget.state.timeAllowedMinutes > 0
        ? widget.state.timeAllowedMinutes
        : 90;
    _titleController = TextEditingController(
      text: '${widget.subject['name'] ?? 'Subject'} Examination',
    );
    _classController = TextEditingController(
      text: widget.state.className.isNotEmpty
          ? widget.state.className
          : 'Class 10',
    );
    _minutesController = TextEditingController(text: '$_selectedMinutes');

    // Initialize defaults
    _resetQuestionsOnlyDefaults();
    _resetHybridDefaults();

    // Do not auto-select alternative sections by default
  }

  @override
  void dispose() {
    _titleController.dispose();
    _classController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  void _resetQuestionsOnlyDefaults() {
    _veryShortMarks = 1;
    _shortMarks = 3;
    _longMarks = 5;

    final target = widget.state.totalMarks;
    _longQ = (target * 0.4) ~/ _longMarks;
    _shortQ = (target * 0.35) ~/ _shortMarks;
    final remaining = target - (_longQ * _longMarks) - (_shortQ * _shortMarks);
    _veryShortQ = remaining > 0 ? remaining ~/ _veryShortMarks : 0;
  }

  void _resetHybridDefaults() {
    _hybridMcqMarks = 1;
    _hybridVeryShortMarks = 1;
    _hybridShortMarks = 3;
    _hybridLongMarks = 5;

    final target = widget.state.totalMarks;
    _hybridLongQ = (target * 0.3) ~/ _hybridLongMarks;
    _hybridShortQ = (target * 0.3) ~/ _hybridShortMarks;
    _hybridMcqQ = (target * 0.3) ~/ _hybridMcqMarks;
    final rem =
        target -
        (_hybridLongQ * _hybridLongMarks) -
        (_hybridShortQ * _hybridShortMarks) -
        (_hybridMcqQ * _hybridMcqMarks);
    _hybridVeryShortQ = rem > 0 ? rem ~/ _hybridVeryShortMarks : 0;
  }

  int get _questionsOnlyTotalMarks =>
      (_veryShortQ * _veryShortMarks) +
      (_shortQ * _shortMarks) +
      (_longQ * _longMarks);
  bool get _isQuestionsOnlyValid =>
      _questionsOnlyTotalMarks == widget.state.totalMarks;

  int get _hybridTotalMarks =>
      (_hybridMcqQ * _hybridMcqMarks) +
      (_hybridVeryShortQ * _hybridVeryShortMarks) +
      (_hybridShortQ * _hybridShortMarks) +
      (_hybridLongQ * _hybridLongMarks);
  bool get _isHybridValid => _hybridTotalMarks == widget.state.totalMarks;

  int get _currentAllocatedMarks {
    switch (_selectedFormat) {
      case 1:
        return _mcqQuestions * _mcqMarksEach;
      case 2:
        return _questionsOnlyTotalMarks;
      case 3:
        return _hybridTotalMarks;
      default:
        return 0;
    }
  }

  bool get _isStage0Valid {
    if (_selectedFormat == 1) return _mcqRemainder == 0 && _mcqQuestions > 0;
    if (_selectedFormat == 2) return _isQuestionsOnlyValid;
    if (_selectedFormat == 3) return _isHybridValid;
    return false;
  }

  String get _formatName {
    switch (_selectedFormat) {
      case 1:
        return 'MCQ Only';
      case 2:
        return 'Subjective Only';
      case 3:
        return 'Hybrid';
      default:
        return 'Custom';
    }
  }

  int get _totalSectionsCount {
    switch (_selectedFormat) {
      case 1:
        return 1;
      case 2:
        int count = 0;
        if (_veryShortQ > 0) count++;
        if (_shortQ > 0) count++;
        if (_longQ > 0) count++;
        return count;
      case 3:
        int count = 0;
        if (_hybridMcqQ > 0) count++;
        if (_hybridVeryShortQ > 0) count++;
        if (_hybridShortQ > 0) count++;
        if (_hybridLongQ > 0) count++;
        return count;
      default:
        return 0;
    }
  }

  int get _totalQuestionsCount {
    switch (_selectedFormat) {
      case 1:
        return _mcqQuestions;
      case 2:
        return _veryShortQ + _shortQ + _longQ;
      case 3:
        return _hybridMcqQ + _hybridVeryShortQ + _hybridShortQ + _hybridLongQ;
      default:
        return 0;
    }
  }

  List<FormatSectionSummary> _getActiveSections() {
    switch (_selectedFormat) {
      case 1:
        return [
          FormatSectionSummary(
            name: 'Section A',
            typeName: 'MCQ',
            questionType: 'MCQ',
            count: _mcqQuestions,
            marksEach: _mcqMarksEach,
          ),
        ];
      case 2:
        final list = <FormatSectionSummary>[];
        if (_veryShortQ > 0) {
          list.add(
            FormatSectionSummary(
              name: 'Section A',
              typeName: 'Very Short',
              questionType: 'VERY_SHORT_ANSWER',
              count: _veryShortQ,
              marksEach: _veryShortMarks,
            ),
          );
        }
        if (_shortQ > 0) {
          list.add(
            FormatSectionSummary(
              name: 'Section B',
              typeName: 'Short Answer',
              questionType: 'SHORT_ANSWER',
              count: _shortQ,
              marksEach: _shortMarks,
            ),
          );
        }
        if (_longQ > 0) {
          list.add(
            FormatSectionSummary(
              name: 'Section C',
              typeName: 'Long Answer',
              questionType: 'LONG_ANSWER',
              count: _longQ,
              marksEach: _longMarks,
            ),
          );
        }
        return list;
      case 3:
        final list = <FormatSectionSummary>[];
        if (_hybridMcqQ > 0) {
          list.add(
            FormatSectionSummary(
              name: 'Section A',
              typeName: 'MCQ',
              questionType: 'MCQ',
              count: _hybridMcqQ,
              marksEach: _hybridMcqMarks,
            ),
          );
        }
        if (_hybridVeryShortQ > 0) {
          list.add(
            FormatSectionSummary(
              name: 'Section B',
              typeName: 'Very Short',
              questionType: 'VERY_SHORT_ANSWER',
              count: _hybridVeryShortQ,
              marksEach: _hybridVeryShortMarks,
            ),
          );
        }
        if (_hybridShortQ > 0) {
          list.add(
            FormatSectionSummary(
              name: 'Section C',
              typeName: 'Short Answer',
              questionType: 'SHORT_ANSWER',
              count: _hybridShortQ,
              marksEach: _hybridShortMarks,
            ),
          );
        }
        if (_hybridLongQ > 0) {
          list.add(
            FormatSectionSummary(
              name: 'Section D',
              typeName: 'Long Answer',
              questionType: 'LONG_ANSWER',
              count: _hybridLongQ,
              marksEach: _hybridLongMarks,
            ),
          );
        }
        return list;
      default:
        return [];
    }
  }

  List<String> get _validSelectedSections {
    final sections = _getActiveSections();
    if (sections.isEmpty) return [];
    final validNames = sections.map((s) => s.name).toSet();
    return _selectedAlternativeSections
        .where((name) => validNames.contains(name))
        .toList();
  }

  Map<String, dynamic> _buildSingleSectionConfig({
    required String sectionName,
    required String questionType,
    required int questionCount,
    required int marksPerQuestion,
  }) {
    int alternativesPerQuestion = 1;
    int? attemptQuestionCount;
    int orSectionsCount = 0;
    bool hasInternalChoice = false;
    int finalQuestionCount = questionCount;

    if (_hasAlternativeQuestions &&
        _validSelectedSections.contains(sectionName)) {
      hasInternalChoice = true;
      if (_alternativeType == 1) {
        // 1) Simple OR (every question has an alternative): "alternatives_per_question": 2
        alternativesPerQuestion = 2;
        attemptQuestionCount = null;
        orSectionsCount = 0;
      } else if (_alternativeType == 2) {
        // 2) Attempt x out of y questions: "attempt_question_count": number
        alternativesPerQuestion = 1;
        final yCount =
            _attemptQuestionCounts[sectionName] ?? (questionCount + 1);
        finalQuestionCount = yCount;
        attemptQuestionCount = questionCount;
        orSectionsCount = 0;
      } else if (_alternativeType == 3) {
        // 3) Either this section or that section: "or_sections_count": 1
        alternativesPerQuestion = 1;
        attemptQuestionCount = null;
        orSectionsCount = 1;
      }
    }

    return {
      'section_name': sectionName,
      'question_type': questionType,
      'question_count': finalQuestionCount,
      'marks_per_question': marksPerQuestion,
      'alternatives_per_question': alternativesPerQuestion,
      'attempt_question_count': attemptQuestionCount,
      'or_sections_count': orSectionsCount,
      'has_internal_choice': hasInternalChoice,
    };
  }

  List<Map<String, dynamic>> _buildQuestionConfigs() {
    switch (_selectedFormat) {
      case 1:
        return [
          _buildSingleSectionConfig(
            sectionName: 'Section A',
            questionType: 'MCQ',
            questionCount: _mcqQuestions,
            marksPerQuestion: _mcqMarksEach,
          ),
        ];
      case 2:
        final configs = <Map<String, dynamic>>[];
        if (_veryShortQ > 0) {
          configs.add(
            _buildSingleSectionConfig(
              sectionName: 'Section A',
              questionType: 'VERY_SHORT_ANSWER',
              questionCount: _veryShortQ,
              marksPerQuestion: _veryShortMarks,
            ),
          );
        }
        if (_shortQ > 0) {
          configs.add(
            _buildSingleSectionConfig(
              sectionName: 'Section B',
              questionType: 'SHORT_ANSWER',
              questionCount: _shortQ,
              marksPerQuestion: _shortMarks,
            ),
          );
        }
        if (_longQ > 0) {
          configs.add(
            _buildSingleSectionConfig(
              sectionName: 'Section C',
              questionType: 'LONG_ANSWER',
              questionCount: _longQ,
              marksPerQuestion: _longMarks,
            ),
          );
        }
        return configs;
      case 3:
        final configs = <Map<String, dynamic>>[];
        if (_hybridMcqQ > 0) {
          configs.add(
            _buildSingleSectionConfig(
              sectionName: 'Section A',
              questionType: 'MCQ',
              questionCount: _hybridMcqQ,
              marksPerQuestion: _hybridMcqMarks,
            ),
          );
        }
        if (_hybridVeryShortQ > 0) {
          configs.add(
            _buildSingleSectionConfig(
              sectionName: 'Section B',
              questionType: 'VERY_SHORT_ANSWER',
              questionCount: _hybridVeryShortQ,
              marksPerQuestion: _hybridVeryShortMarks,
            ),
          );
        }
        if (_hybridShortQ > 0) {
          configs.add(
            _buildSingleSectionConfig(
              sectionName: 'Section C',
              questionType: 'SHORT_ANSWER',
              questionCount: _hybridShortQ,
              marksPerQuestion: _hybridShortMarks,
            ),
          );
        }
        if (_hybridLongQ > 0) {
          configs.add(
            _buildSingleSectionConfig(
              sectionName: 'Section D',
              questionType: 'LONG_ANSWER',
              questionCount: _hybridLongQ,
              marksPerQuestion: _hybridLongMarks,
            ),
          );
        }
        return configs;
      default:
        return [];
    }
  }

  void _handleGenerate() {
    final title = _titleController.text.trim().isNotEmpty
        ? _titleController.text.trim()
        : '${widget.subject['name'] ?? 'Subject'} Paper';
    final className = _classController.text.trim().isNotEmpty
        ? _classController.text.trim()
        : 'Class 10';
    final minutes =
        int.tryParse(_minutesController.text.trim()) ?? _selectedMinutes;

    widget.state.className = className;
    widget.state.timeAllowedMinutes = minutes;
    widget.state.enableNumericalPercentage = _enableNumericalQuestions;
    widget.state.numericalPercentage = _enableNumericalQuestions
        ? _numericalPercentage.round()
        : 0;
    widget.state.enableAlternatives = _hasAlternativeQuestions;
    widget.state.alternativeType = _alternativeType;
    widget.state.alternativeSectionNames = _validSelectedSections;
    widget.state.attemptQuestionCounts =
        (_hasAlternativeQuestions && _alternativeType == 2)
        ? _attemptQuestionCounts
        : {};
    widget.state.questionConfigs = _buildQuestionConfigs();

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
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    return PopScope(
      canPop: _currentStage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentStage == 1) {
          setState(() => _currentStage = 0);
        }
      },
      child: Scaffold(
        backgroundColor: WorkspaceTheme.canvas,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                children: [
                  // Header
                  WizardStepHeader(
                    subjectName: widget.subject['name'] ?? 'Subject',
                    currentStep: 5,
                    title: _currentStage == 0
                        ? 'Question Format'
                        : 'Exam Details',
                    subtitle: _currentStage == 0
                        ? 'Choose layout pattern and configure section marks'
                        : 'Set exam title, duration and optional formats',
                    onBack: () {
                      if (_currentStage == 1) {
                        setState(() => _currentStage = 0);
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    trailing: _currentStage == 1
                        ? TextButton.icon(
                            onPressed: () => setState(() => _currentStage = 0),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 14,
                              color: AuthTheme.accentSky,
                            ),
                            label: const Text(
                              'Layout',
                              style: TextStyle(
                                fontFamily: AuthTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AuthTheme.accentSky,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                        : null,
                  ),

                  // Stage switcher progress pill
                  _buildSubStageIndicator(),

                  // Active Stage Content
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _currentStage == 0
                          ? _buildStage0Content()
                          : _buildStage1Content(),
                    ),
                  ),

                  // Bottom Action Bar
                  WizardBottomBar(
                    text: _currentStage == 0
                        ? 'Continue to Paper Details'
                        : 'Generate Paper',
                    icon: _currentStage == 0
                        ? Icons.arrow_forward_rounded
                        : Icons.auto_awesome_rounded,
                    onPressed: _currentStage == 0
                        ? (_isStage0Valid
                              ? () => setState(() => _currentStage = 1)
                              : null)
                        : _handleGenerate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Stage Switcher Pill Indicator ──────────────────
  Widget _buildSubStageIndicator() {
    return Container(
      color: WorkspaceTheme.surfaceWhite,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentStage = 0),
              child: _buildStageTabItem(
                stepIndex: 1,
                title: 'Section Layout',
                isActive: _currentStage == 0,
                isCompleted: _isStage0Valid,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: _isStage0Valid
                  ? () => setState(() => _currentStage = 1)
                  : null,
              child: _buildStageTabItem(
                stepIndex: 2,
                title: 'Paper Details',
                isActive: _currentStage == 1,
                isCompleted: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageTabItem({
    required int stepIndex,
    required String title,
    required bool isActive,
    required bool isCompleted,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
      decoration: BoxDecoration(
        color: isActive
            ? (WorkspaceTheme.isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFEFF6FF))
            : WorkspaceTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isActive
              ? (WorkspaceTheme.isDark
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFBAE6FD))
              : WorkspaceTheme.borderSubtle,
          width: isActive ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? AuthTheme.accentSky
                  : (isCompleted ? AuthTheme.success : const Color(0xFFCBD5E1)),
              shape: BoxShape.circle,
            ),
            child: isCompleted && !isActive
                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                : Text(
                    '$stepIndex',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 11.5,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive
                    ? (WorkspaceTheme.isDark
                          ? const Color(0xFF93C5FD)
                          : const Color(0xFF0369A1))
                    : WorkspaceTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // STAGE 0: Question Layout & Section Marks Distribution
  // ─────────────────────────────────────────────────────────
  Widget _buildStage0Content() {
    return SingleChildScrollView(
      key: const ValueKey('stage0'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Heading
          const Text(
            'SELECT LAYOUT PATTERN',
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AuthTheme.textTertiary,
            ),
          ),
          const SizedBox(height: 10),

          // Clean Horizontal Pattern Selector (No expanding vertical accordion!)
          Row(
            children: [
              Expanded(
                child: _buildPatternOptionCard(
                  index: 1,
                  title: 'MCQ Only',
                  subtitle: '1 Section',
                  icon: Icons.check_box_outlined,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPatternOptionCard(
                  index: 2,
                  title: 'Subjective',
                  subtitle: '3 Sections',
                  icon: Icons.notes_rounded,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPatternOptionCard(
                  index: 3,
                  title: 'Hybrid',
                  subtitle: '4 Sections',
                  icon: Icons.dashboard_customize_outlined,
                  color: const Color(0xFF10B981),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Pinned Real-Time Marks Balance Strip
          _buildMarksBalanceStrip(),

          const SizedBox(height: 18),

          // Selected Layout's Section Configuration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_formatName SECTIONS',
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: AuthTheme.textTertiary,
                ),
              ),
              Text(
                '$_totalQuestionsCount Questions',
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AuthTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Render only active format sections
          if (_selectedFormat == 1) _buildMcqSectionView(),
          if (_selectedFormat == 2) _buildSubjectiveSectionView(),
          if (_selectedFormat == 3) _buildHybridSectionView(),
        ],
      ),
    );
  }

  Widget _buildPatternOptionCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedFormat == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFormat = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? WorkspaceTheme.surfaceWhite
              : WorkspaceTheme.surfaceMuted,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : WorkspaceTheme.borderSubtle,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.15)
                    : (WorkspaceTheme.isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? color : WorkspaceTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? WorkspaceTheme.textPrimary
                    : WorkspaceTheme.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 11,
                color: isSelected ? color : WorkspaceTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksBalanceStrip() {
    final target = widget.state.totalMarks;
    final current = _currentAllocatedMarks;
    final isBalanced = _isStage0Valid;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBalanced ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isBalanced
                ? AuthTheme.success.withValues(alpha: 0.05)
                : const Color(0xFFD97706).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isBalanced
                    ? Icons.check_circle_rounded
                    : Icons.pending_outlined,
                color: isBalanced ? AuthTheme.success : const Color(0xFFD97706),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 13,
                      color: AuthTheme.textPrimary,
                    ),
                    children: [
                      const TextSpan(text: 'Marks Allocated: '),
                      TextSpan(
                        text: '$current',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: isBalanced
                              ? AuthTheme.success
                              : const Color(0xFFD97706),
                        ),
                      ),
                      TextSpan(
                        text: ' / $target Total',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AuthTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: target > 0 ? (current / target).clamp(0.0, 1.0) : 0,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(
                isBalanced ? AuthTheme.success : const Color(0xFFF59E0B),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  // ── Format 1: MCQ Section View ─────────────────────
  Widget _buildMcqSectionView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Section A: MCQs',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: WorkspaceTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Score allocated per question',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 11.5,
                        color: WorkspaceTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStepper(
                value: _mcqMarksEach,
                unit: ' mark',
                onDec: _mcqMarksEach > 1
                    ? () => setState(() => _mcqMarksEach--)
                    : null,
                onInc: () => setState(() => _mcqMarksEach++),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: WorkspaceTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WorkspaceTheme.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Questions Generated:',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: WorkspaceTheme.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '$_mcqQuestions questions',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: WorkspaceTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (_mcqRemainder != 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: AuthTheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Total marks (${widget.state.totalMarks}) cannot be divided evenly by $_mcqMarksEach.',
                      style: const TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 11,
                        color: AuthTheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Format 2: Subjective Only View ─────────────────
  Widget _buildSubjectiveSectionView() {
    return Column(
      children: [
        _buildSectionCard(
          sectionLabel: 'Section A: Very Short Answer',
          marks: _veryShortMarks,
          onMarksChanged: (m) => setState(() => _veryShortMarks = m),
          count: _veryShortQ,
          onCountChanged: (c) => setState(() => _veryShortQ = c),
        ),
        const SizedBox(height: 10),
        _buildSectionCard(
          sectionLabel: 'Section B: Short Answer',
          marks: _shortMarks,
          onMarksChanged: (m) => setState(() => _shortMarks = m),
          count: _shortQ,
          onCountChanged: (c) => setState(() => _shortQ = c),
        ),
        const SizedBox(height: 10),
        _buildSectionCard(
          sectionLabel: 'Section C: Long Answer',
          marks: _longMarks,
          onMarksChanged: (m) => setState(() => _longMarks = m),
          count: _longQ,
          onCountChanged: (c) => setState(() => _longQ = c),
        ),
      ],
    );
  }

  // ── Format 3: Hybrid View ──────────────────────────
  Widget _buildHybridSectionView() {
    return Column(
      children: [
        _buildSectionCard(
          sectionLabel: 'Section A: Multiple Choice Questions',
          marks: _hybridMcqMarks,
          onMarksChanged: (m) => setState(() => _hybridMcqMarks = m),
          count: _hybridMcqQ,
          onCountChanged: (c) => setState(() => _hybridMcqQ = c),
        ),
        const SizedBox(height: 10),
        _buildSectionCard(
          sectionLabel: 'Section B: Very Short Answer',
          marks: _hybridVeryShortMarks,
          onMarksChanged: (m) => setState(() => _hybridVeryShortMarks = m),
          count: _hybridVeryShortQ,
          onCountChanged: (c) => setState(() => _hybridVeryShortQ = c),
        ),
        const SizedBox(height: 10),
        _buildSectionCard(
          sectionLabel: 'Section C: Short Answer',
          marks: _hybridShortMarks,
          onMarksChanged: (m) => setState(() => _hybridShortMarks = m),
          count: _hybridShortQ,
          onCountChanged: (c) => setState(() => _hybridShortQ = c),
        ),
        const SizedBox(height: 10),
        _buildSectionCard(
          sectionLabel: 'Section D: Long Answer',
          marks: _hybridLongMarks,
          onMarksChanged: (m) => setState(() => _hybridLongMarks = m),
          count: _hybridLongQ,
          onCountChanged: (c) => setState(() => _hybridLongQ = c),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String sectionLabel,
    required int marks,
    required ValueChanged<int> onMarksChanged,
    required int count,
    required ValueChanged<int> onCountChanged,
  }) {
    final subtotal = marks * count;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sectionLabel,
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: WorkspaceTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: subtotal > 0
                      ? (WorkspaceTheme.isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFEFF6FF))
                      : WorkspaceTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$subtotal Marks',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: subtotal > 0
                        ? (WorkspaceTheme.isDark
                              ? const Color(0xFF38BDF8)
                              : const Color(0xFF0284C7))
                        : WorkspaceTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Marks each stepper
              Row(
                children: [
                  Text(
                    'Marks: ',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: WorkspaceTheme.textSecondary,
                    ),
                  ),
                  _buildStepper(
                    value: marks,
                    unit: 'm',
                    onDec: marks > 1 ? () => onMarksChanged(marks - 1) : null,
                    onInc: () => onMarksChanged(marks + 1),
                  ),
                ],
              ),
              // Questions count stepper
              Row(
                children: [
                  Text(
                    'Qty: ',
                    style: TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: WorkspaceTheme.textSecondary,
                    ),
                  ),
                  _buildStepper(
                    value: count,
                    unit: '',
                    onDec: count > 0 ? () => onCountChanged(count - 1) : null,
                    onInc: () => onCountChanged(count + 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepper({
    required int value,
    required String unit,
    required VoidCallback? onDec,
    required VoidCallback onInc,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onDec,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onDec != null
                  ? WorkspaceTheme.surfaceWhite
                  : WorkspaceTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WorkspaceTheme.borderSubtle),
            ),
            child: Icon(
              Icons.remove_rounded,
              size: 15,
              color: onDec != null
                  ? WorkspaceTheme.textPrimary
                  : WorkspaceTheme.textSecondary,
            ),
          ),
        ),
        Container(
          constraints: const BoxConstraints(minWidth: 32),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            unit.isEmpty ? '$value' : '$value$unit',
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: WorkspaceTheme.textPrimary,
            ),
          ),
        ),
        GestureDetector(
          onTap: onInc,
          child: Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: WorkspaceTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: WorkspaceTheme.borderSubtle),
            ),
            child: Icon(
              Icons.add_rounded,
              size: 15,
              color: WorkspaceTheme.accentCobalt,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────
  // STAGE 1: Exam Details & Generation
  // ─────────────────────────────────────────────────────────
  Widget _buildStage1Content() {
    return SingleChildScrollView(
      key: const ValueKey('stage1'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Configuration Summary Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: WorkspaceTheme.isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: WorkspaceTheme.isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFBAE6FD),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryBadge(
                  label: 'Total Marks',
                  value: '${widget.state.totalMarks}M',
                  icon: Icons.score_outlined,
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: WorkspaceTheme.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFBAE6FD),
                ),
                _buildSummaryBadge(
                  label: 'Format',
                  value: _formatName,
                  icon: Icons.layers_outlined,
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: WorkspaceTheme.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFBAE6FD),
                ),
                _buildSummaryBadge(
                  label: 'Sections',
                  value: '$_totalSectionsCount',
                  icon: Icons.segment_rounded,
                ),
                Container(
                  width: 1,
                  height: 28,
                  color: WorkspaceTheme.isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFBAE6FD),
                ),
                _buildSummaryBadge(
                  label: 'Questions',
                  value: '$_totalQuestionsCount',
                  icon: Icons.quiz_outlined,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Paper Title & Class Details
          Text(
            'PAPER METADATA',
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: WorkspaceTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          AuthTextField(
            label: 'Paper Title',
            hintText: 'e.g. Mid-Term Examination 2026',
            prefixIcon: Icons.description_outlined,
            controller: _titleController,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 14),

          AuthTextField(
            label: 'Class / Grade',
            hintText: 'e.g. Class 10th (Section A)',
            prefixIcon: Icons.school_outlined,
            controller: _classController,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 20),

          // Duration Configuration
          Text(
            'EXAM DURATION',
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: WorkspaceTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          AuthTextField(
            label: 'Time Allowed (in minutes)',
            hintText: 'e.g. 60',
            prefixIcon: Icons.timer_outlined,
            controller: _minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.done,
            suffix: Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  'mins',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: WorkspaceTheme.accentCobalt,
                  ),
                ),
              ),
            ),
            onChanged: (val) {
              final parsed = int.tryParse(val.trim());
              if (parsed != null && parsed > 0) {
                setState(() => _selectedMinutes = parsed);
              }
            },
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [45, 60, 90, 120, 180].map((mins) {
              final isSel = _selectedMinutes == mins;
              return ChoiceChip(
                label: Text('${mins}m'),
                selected: isSel,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedMinutes = mins;
                      _minutesController.text = '$mins';
                    });
                  }
                },
                selectedColor: WorkspaceTheme.isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFEFF6FF),
                backgroundColor: WorkspaceTheme.surfaceWhite,
                labelStyle: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                  color: isSel
                      ? WorkspaceTheme.accentCobalt
                      : WorkspaceTheme.textSecondary,
                ),
                side: BorderSide(
                  color: isSel
                      ? (WorkspaceTheme.isDark
                            ? const Color(0xFF3B82F6)
                            : const Color(0xFFBAE6FD))
                      : WorkspaceTheme.borderSubtle,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Advanced Options
          Text(
            'ADVANCED FORMAT OPTIONS',
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: WorkspaceTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),

          // Alternatives / Choice Selector Card
          AlternativeTypeSelector(
            isEnabled: _hasAlternativeQuestions,
            onToggleEnabled: (val) {
              setState(() {
                _hasAlternativeQuestions = val;
              });
            },
            selectedType: _alternativeType,
            onTypeChanged: (type) {
              setState(() {
                _alternativeType = type;
                if (type == 2) {
                  // Deselect sections that have 1 or fewer questions
                  final sections = _getActiveSections();
                  final validNames = sections
                      .where((s) => s.count > 1)
                      .map((s) => s.name)
                      .toSet();
                  _selectedAlternativeSections.removeWhere(
                    (name) => !validNames.contains(name),
                  );
                }
              });
            },
            sections: _getActiveSections(),
            selectedSections: _validSelectedSections,
            onSectionsChanged: (sections) {
              setState(() {
                _selectedAlternativeSections = sections;
              });
            },
            attemptCounts: _attemptQuestionCounts,
            onAttemptCountsChanged: (counts) =>
                setState(() => _attemptQuestionCounts = counts),
          ),

          const SizedBox(height: 14),

          // Numerical questions card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: WorkspaceTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: WorkspaceTheme.borderSubtle),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Numerical Questions',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: WorkspaceTheme.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Specify percentage of numerical problems',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 12,
                              color: WorkspaceTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      activeThumbColor: WorkspaceTheme.accentCobalt,
                      activeTrackColor: WorkspaceTheme.accentCobalt.withValues(
                        alpha: 0.35,
                      ),
                      value: _enableNumericalQuestions,
                      onChanged: (val) =>
                          setState(() => _enableNumericalQuestions = val),
                    ),
                  ],
                ),
                if (_enableNumericalQuestions) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Numerical Ratio',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: WorkspaceTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${_numericalPercentage.round()}%',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: WorkspaceTheme.accentCobalt,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _numericalPercentage,
                    min: 5,
                    max: 60,
                    divisions: 11,
                    activeColor: WorkspaceTheme.accentCobalt,
                    onChanged: (v) => setState(() => _numericalPercentage = v),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: WorkspaceTheme.accentCobalt),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: WorkspaceTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 10,
            color: WorkspaceTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
