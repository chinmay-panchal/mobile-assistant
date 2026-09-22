import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../../../../core/widgets/svg_diagram_viewer.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

/// Redesigned PaperEditorScreen matching the Papervisor design system.
/// Features a sticky modern header, clean general information inputs,
/// non-editable calculated total marks, and expandable question cards.
class PaperEditorScreen extends StatefulWidget {
  final Map<String, dynamic> paper;

  const PaperEditorScreen({super.key, required this.paper});

  @override
  State<PaperEditorScreen> createState() => _PaperEditorScreenState();
}

class _PaperEditorScreenState extends State<PaperEditorScreen> {
  late Map<String, dynamic> _editablePaper;

  // Controllers for header
  late TextEditingController _titleCtrl;
  late TextEditingController _classCtrl;
  late TextEditingController _timeCtrl;

  @override
  void initState() {
    super.initState();
    _editablePaper = _cloneMap(widget.paper);

    _titleCtrl = TextEditingController(
      text: (_editablePaper['title'] ?? _editablePaper['paper_title'] ?? '').toString(),
    );
    _classCtrl = TextEditingController(text: _editablePaper['class_name'] ?? '');
    _timeCtrl = TextEditingController(
      text: (_editablePaper['time_allowed_minutes'] ?? '').toString(),
    );

    if (_editablePaper['questions'] == null && _editablePaper['content'] != null) {
      final content = _editablePaper['content'];
      if (content is Map) {
        if (content['questions'] is List) {
          _editablePaper['questions'] = content['questions'];
        } else if (content['sections'] is List) {
          final flatQuestions = <dynamic>[];
          for (final sec in content['sections']) {
            if (sec is Map && sec['questions'] is List) {
              for (final q in sec['questions']) {
                if (q is Map) {
                  q['section_name'] ??= sec['name'] ?? sec['title'];
                  flatQuestions.add(q);
                }
              }
            }
          }
          _editablePaper['questions'] = flatQuestions;
        }
      }
    }

    _recalculateTotalMarks();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _classCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  Map<String, dynamic> _cloneMap(Map<String, dynamic> map) {
    final Map<String, dynamic> cloned = {};
    map.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        cloned[key] = _cloneMap(value);
      } else if (value is List) {
        cloned[key] = _cloneList(value);
      } else {
        cloned[key] = value;
      }
    });
    return cloned;
  }

  List<dynamic> _cloneList(List<dynamic> list) {
    final List<dynamic> cloned = [];
    for (var item in list) {
      if (item is Map<String, dynamic>) {
        cloned.add(_cloneMap(item));
      } else if (item is List) {
        cloned.add(_cloneList(item));
      } else {
        cloned.add(item);
      }
    }
    return cloned;
  }

  void _recalculateTotalMarks() {
    int total = 0;
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];

    String? currentChoiceGroup;
    for (final q in questions) {
      final String? choiceGroup = q['choice_group'];
      if (choiceGroup == null || choiceGroup != currentChoiceGroup) {
        final qm = (q['marks'] as num?)?.toInt() ?? 1;
        total += (qm < 1 ? 1 : qm);
        currentChoiceGroup = choiceGroup;
      }
    }
    if (total < 1) total = 1;

    setState(() {
      _editablePaper['total_marks'] = total;
    });
  }

  void _saveChanges() {
    final titleText = _titleCtrl.text.trim();
    _editablePaper['title'] = titleText;
    if (_editablePaper.containsKey('paper_title')) {
      _editablePaper['paper_title'] = titleText;
    }
    _editablePaper['class_name'] = _classCtrl.text.trim();
    final timeVal = int.tryParse(_timeCtrl.text.trim()) ?? 1;
    _editablePaper['time_allowed_minutes'] = timeVal < 1 ? 1 : timeVal;

    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    for (final q in questions) {
      final m = (q['marks'] as num?)?.toInt() ?? 1;
      if (m < 1) {
        q['marks'] = 1;
      }
    }
    _recalculateTotalMarks();

    Navigator.pop(context, _editablePaper);
  }

  @override
  Widget build(BuildContext context) {
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];

    return Scaffold(
      backgroundColor: AuthTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Modern Header
            Container(
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Edit Paper',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AuthTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 86,
                    height: 38,
                    child: AuthPrimaryButton(
                      text: 'Save',
                      height: 38,
                      onPressed: _saveChanges,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content Editor
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Paper Information
                    const Text(
                      'Paper Information',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AuthTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabeledInput(
                            label: 'Paper Title',
                            controller: _titleCtrl,
                            hintText: 'e.g. Mid-Term Examination 2024',
                            icon: Icons.title_rounded,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildLabeledInput(
                                  label: 'Academic Level',
                                  controller: _classCtrl,
                                  hintText: 'e.g. Class 10th',
                                  icon: Icons.school_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildLabeledInput(
                                  label: 'Time (minutes)',
                                  controller: _timeCtrl,
                                  hintText: 'e.g. 180',
                                  icon: Icons.timer_outlined,
                                  isNumber: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section 2: Calculated Total Marks (Read-Only)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.calculate_rounded,
                              color: AuthTheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Marks',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AuthTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Automatically calculated from questions.',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 11,
                                    color: AuthTheme.primary.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_editablePaper['total_marks'] ?? 0}',
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: AuthTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section 3: Questions List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Questions',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AuthTheme.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(AuthTheme.radiusPill),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            '${questions.length} ${questions.length == 1 ? "item" : "items"}',
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AuthTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      itemBuilder: (context, index) {
                        return _buildQuestionCard(questions[index], index);
                      },
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledInput({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AuthTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: const TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AuthTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 13,
              color: AuthTheme.textTertiary,
            ),
            prefixIcon: Icon(icon, size: 18, color: AuthTheme.textTertiary),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide: const BorderSide(color: AuthTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final rawText = question['question_text'] ?? question['question'] ?? 'Empty Question';
    final qText = TextSanitizer.cleanLaTeX(rawText.toString());
    final previewText = qText.length > 50 ? '${qText.substring(0, 50)}...' : qText;
    final rawMarks = (question['marks'] as num?)?.toInt() ?? 1;
    final marks = rawMarks < 1 ? 1 : rawMarks;
    final section = (question['section_name'] ?? '').toString();

    final List<dynamic> opts = question['mcq_options'] ?? question['options'] ?? [];
    final bool isMcq = opts.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AuthTheme.radiusCard),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  'Q${index + 1}',
                  style: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  previewText,
                  style: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AuthTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Row(
              children: [
                // Marks Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '$marks ${marks == 1 ? "Mark" : "Marks"}',
                    style: const TextStyle(
                      fontFamily: AuthTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AuthTheme.textSecondary,
                    ),
                  ),
                ),

                if (section.isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Sec: $section',
                      style: const TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AuthTheme.textSecondary,
                      ),
                    ),
                  ),
                ],

                if (isMcq) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'MCQ',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ),
                ],

                if (question['visual_svg'] != null &&
                    question['visual_svg'].toString().trim().isNotEmpty) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF2F8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.hub_outlined, size: 10, color: Color(0xFFDB2777)),
                        SizedBox(width: 2),
                        Text(
                          'Diagram',
                          style: TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFDB2777),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 14),

            // Question Text Input
            const Text(
              'Question Text',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AuthTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              initialValue: (question['question_text'] ?? question['question'] ?? '').toString(),
              maxLines: null,
              onChanged: (val) {
                setState(() {
                  question['question_text'] = val;
                  if (question.containsKey('question')) {
                    question['question'] = val;
                  }
                });
              },
              style: const TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Enter question text...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 14),

            // Marks and Section Row
            Row(
              children: [
                Expanded(
                  child: _QuestionMarksField(
                    initialMarks: marks,
                    onChanged: (val) {
                      question['marks'] = val;
                      _recalculateTotalMarks();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Section Name',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AuthTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        initialValue: question['section_name'] ?? '',
                        onChanged: (val) {
                          setState(() {
                            question['section_name'] = val;
                          });
                        },
                        style: const TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Section A',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (question['visual_svg'] != null &&
                question['visual_svg'].toString().trim().isNotEmpty) ...[
              const SizedBox(height: 14),
              SvgDiagramViewer(
                rawSvg: question['visual_svg']?.toString(),
                title: question['visual_title']?.toString(),
                caption: question['visual_caption']?.toString(),
              ),
            ],

            // MCQ Options if present
            if (isMcq) ...[
              const SizedBox(height: 14),
              const Text(
                'Answer Options',
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AuthTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(opts.length, (optIndex) {
                final option = opts[optIndex];
                final isMap = option is Map;
                final initialVal = isMap
                    ? (option['option_text'] ?? option['text'] ?? '')
                    : option.toString();

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + optIndex),
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AuthTheme.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          initialValue: initialVal,
                          onChanged: (val) {
                            if (isMap) {
                              if (option.containsKey('option_text')) {
                                option['option_text'] = val;
                              } else if (option.containsKey('text')) {
                                option['text'] = val;
                              }
                            } else {
                              opts[optIndex] = val;
                            }
                          },
                          style: const TextStyle(
                            fontFamily: AuthTheme.fontFamily,
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
        ),
      ),
    );
  }
}

class _QuestionMarksField extends StatefulWidget {
  final int initialMarks;
  final ValueChanged<int> onChanged;

  const _QuestionMarksField({
    required this.initialMarks,
    required this.onChanged,
  });

  @override
  State<_QuestionMarksField> createState() => _QuestionMarksFieldState();
}

class _QuestionMarksFieldState extends State<_QuestionMarksField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    final initVal = widget.initialMarks < 1 ? 1 : widget.initialMarks;
    _controller = TextEditingController(text: initVal.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      final text = _controller.text.trim();
      final parsed = int.tryParse(text);
      if (parsed == null || parsed < 1) {
        _controller.text = '1';
        setState(() => _errorText = null);
        widget.onChanged(1);
      }
    }
  }

  void _handleChanged(String val) {
    final text = val.trim();
    if (text.isEmpty) {
      setState(() => _errorText = 'Marks cannot be empty');
      widget.onChanged(1);
      return;
    }

    if (text.contains('.') || text.contains(',')) {
      setState(() => _errorText = 'Decimals not allowed');
      widget.onChanged(1);
      return;
    }

    if (text.contains('-')) {
      setState(() => _errorText = 'Negatives not allowed');
      widget.onChanged(1);
      return;
    }

    final parsed = int.tryParse(text);
    if (parsed == null || parsed < 1) {
      setState(() => _errorText = 'Marks must be ≥ 1');
      widget.onChanged(1);
      return;
    }

    setState(() => _errorText = null);
    widget.onChanged(parsed);
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Marks (Min. 1)',
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AuthTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: _handleChanged,
          onTapOutside: (_) => _focusNode.unfocus(),
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: hasError ? AuthTheme.error : AuthTheme.textPrimary,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AuthTheme.error : const Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AuthTheme.error : const Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? AuthTheme.error : AuthTheme.primary,
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 12, color: AuthTheme.error),
                const SizedBox(width: 4),
                Text(
                  _errorText!,
                  style: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    color: AuthTheme.error,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
