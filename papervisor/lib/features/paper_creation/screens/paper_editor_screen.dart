import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../../../../core/widgets/svg_diagram_viewer.dart';

class PaperEditorScreen extends StatefulWidget {
  final Map<String, dynamic> paper;

  const PaperEditorScreen({Key? key, required this.paper}) : super(key: key);

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

    _titleCtrl = TextEditingController(text: _editablePaper['title'] ?? '');
    _classCtrl = TextEditingController(text: _editablePaper['class_name'] ?? '');
    _timeCtrl = TextEditingController(text: (_editablePaper['time_allowed_minutes'] ?? '').toString());
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
    _editablePaper['title'] = _titleCtrl.text;
    _editablePaper['class_name'] = _classCtrl.text;
    final timeVal = int.tryParse(_timeCtrl.text) ?? 1;
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Edit Paper', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('General Info'),
            _buildTextField('Paper Title', _titleCtrl),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Academic Level (e.g. Class 8)', _classCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField('Time (mins)', _timeCtrl, isNumber: true)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Marks (Auto-calculated)', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('${_editablePaper['total_marks'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Questions (${questions.length})'),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(questions[index], index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.divider)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final rawText = question['question_text'] ?? 'Empty Question';
    final qText = TextSanitizer.cleanLaTeX(rawText.toString());
    final previewText = qText.length > 40 ? '${qText.substring(0, 40)}...' : qText;
    final rawMarks = (question['marks'] as num?)?.toInt() ?? 1;
    final marks = rawMarks < 1 ? 1 : rawMarks;
    final section = question['section_name'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.divider)),
      elevation: 0,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text('Q${index + 1}. $previewText', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle: Row(
            children: [
              Text('Marks: $marks  |  Section: $section', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              if (question['visual_svg'] != null && question['visual_svg'].toString().trim().isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.hub_outlined, size: 11, color: AppColors.primary),
                      SizedBox(width: 3),
                      Text('Diagram', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ],
                  ),
                ),
              ],
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: AppColors.divider),
            const SizedBox(height: 12),
            
            TextFormField(
              initialValue: question['question_text'] ?? '',
              maxLines: null,
              onChanged: (val) {
                setState(() {
                  question['question_text'] = val;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Question Text',
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            
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
                  child: TextFormField(
                    initialValue: question['section_name'] ?? '',
                    onChanged: (val) {
                      setState(() {
                        question['section_name'] = val;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Section',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ],
            ),
            if (question['visual_svg'] != null && question['visual_svg'].toString().trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              SvgDiagramViewer(
                rawSvg: question['visual_svg']?.toString(),
                title: question['visual_title']?.toString(),
                caption: question['visual_caption']?.toString(),
              ),
            ],
            const SizedBox(height: 12),
            
            Builder(
              builder: (context) {
                final List<dynamic> opts = question['mcq_options'] ?? question['options'] ?? [];
                if (opts.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Options', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    ...List.generate(opts.length, (optIndex) {
                      final option = opts[optIndex];
                      final isMap = option is Map;
                      final initialVal = isMap ? (option['option_text'] ?? option['text'] ?? '') : option.toString();

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(String.fromCharCode(65 + optIndex), style: const TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                initialValue: initialVal,
                                onChanged: (val) {
                                  if (isMap) {
                                    if (option.containsKey('option_text')) option['option_text'] = val;
                                    else if (option.containsKey('text')) option['text'] = val;
                                  } else {
                                    opts[optIndex] = val;
                                  }
                                },
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionMarksField extends StatefulWidget {
  final int initialMarks;
  final ValueChanged<int> onChanged;

  const _QuestionMarksField({
    Key? key,
    required this.initialMarks,
    required this.onChanged,
  }) : super(key: key);

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
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: _handleChanged,
          onTapOutside: (_) => _focusNode.unfocus(),
          style: TextStyle(
            color: hasError ? AppColors.error : AppColors.textPrimary,
            fontWeight: hasError ? FontWeight.bold : FontWeight.normal,
          ),
          decoration: InputDecoration(
            labelText: 'Marks (Min. 1)',
            labelStyle: TextStyle(color: hasError ? AppColors.error : AppColors.textSecondary),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? AppColors.error : AppColors.divider, width: hasError ? 2 : 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: hasError ? AppColors.error : AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Row(
              children: [
                const Icon(Icons.error_outline, size: 14, color: AppColors.error),
                const SizedBox(width: 4),
                Text(
                  _errorText!,
                  style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
