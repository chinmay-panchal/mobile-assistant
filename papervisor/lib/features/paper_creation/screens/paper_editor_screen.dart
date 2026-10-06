import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/text_sanitizer.dart';
import '../../../../core/widgets/svg_diagram_viewer.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../auth/theme/auth_theme.dart';
import '../../auth/widgets/auth_primary_button.dart';

class _PaperEditorSnapshot {
  final Map<String, dynamic> paper;
  final String title;
  final String className;
  final String time;

  _PaperEditorSnapshot({
    required this.paper,
    required this.title,
    required this.className,
    required this.time,
  });
}

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

  // Undo / Redo history
  final List<_PaperEditorSnapshot> _undoStack = [];
  final List<_PaperEditorSnapshot> _redoStack = [];
  late _PaperEditorSnapshot _initialSnapshot;

  bool _isApplyingSnapshot = false;
  bool _hasPendingPreEditSnapshot = false;
  Timer? _preEditDebounce;
  int _editRevision = 0;

  @override
  void initState() {
    super.initState();
    _editablePaper = _cloneMap(widget.paper);

    _titleCtrl = TextEditingController(
      text: (_editablePaper['title'] ?? _editablePaper['paper_title'] ?? '')
          .toString(),
    );
    _classCtrl = TextEditingController(
      text: _editablePaper['class_name'] ?? '',
    );
    _timeCtrl = TextEditingController(
      text: (_editablePaper['time_allowed_minutes'] ?? '').toString(),
    );

    if (_editablePaper['questions'] == null &&
        _editablePaper['content'] != null) {
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

    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    for (final q in questions) {
      if (q is Map) {
        if (q['section_name'] == null ||
            q['section_name'].toString().trim().isEmpty) {
          q['section_name'] = 'Section A';
        }
        if (q['marks'] == null || (q['marks'] as num) < 1) {
          q['marks'] = 1;
        }
      }
    }

    _recalculateTotalMarks();

    _initialSnapshot = _takeSnapshot();
    _titleCtrl.addListener(_notifyEdit);
    _classCtrl.addListener(_notifyEdit);
    _timeCtrl.addListener(_notifyEdit);
  }

  String _getBaseSectionName(String rawName) {
    final trimmed = rawName.trim();
    final regex = RegExp(
      r'(\s*\((or|OR|Or)\)|\s*\[(or|OR|Or)\]|\s*\-\s*(or|OR|Or)|\s+\b(OR|or)\b)$',
    );
    final cleaned = trimmed.replaceAll(regex, '').trim();
    return cleaned.isEmpty ? trimmed : cleaned;
  }

  bool _isOrDuplicateSection(String rawName) {
    final trimmed = rawName.trim();
    final regex = RegExp(
      r'(\s*\((or|OR|Or)\)|\s*\[(or|OR|Or)\]|\s*\-\s*(or|OR|Or)|\s+\b(OR|or)\b)$',
    );
    return regex.hasMatch(trimmed);
  }

  bool _sectionHasOrDuplicate(String baseSectionName) {
    final targetBase = baseSectionName.toLowerCase().trim();
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    bool hasOr = false;
    final foundNames = <String>{};

    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        if (_getBaseSectionName(effectiveSec).toLowerCase() == targetBase) {
          foundNames.add(effectiveSec);
          if (_isOrDuplicateSection(effectiveSec)) {
            hasOr = true;
          }
        }
      }
    }
    return hasOr || foundNames.length > 1;
  }

  List<String> _getDistinctSectionNames() {
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    final names = <String>[];
    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        final base = _getBaseSectionName(effectiveSec);
        if (!names.contains(base)) {
          names.add(base);
        }
      }
    }
    if (names.isEmpty) names.add('Section A');
    return names;
  }

  int _getSectionMarks(String baseSectionName) {
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    final targetBase = baseSectionName.toLowerCase().trim();
    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        if (_getBaseSectionName(effectiveSec).toLowerCase() == targetBase) {
          final m = (q['marks'] as num?)?.toInt() ?? 1;
          return m < 1 ? 1 : m;
        }
      }
    }
    return 1;
  }

  int _getSectionQuestionCount(String baseSectionName) {
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    final targetBase = baseSectionName.toLowerCase().trim();
    int count = 0;
    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        if (_getBaseSectionName(effectiveSec).toLowerCase() == targetBase) {
          count++;
        }
      }
    }
    return count;
  }

  int _getPrimarySectionQuestionCount(String baseSectionName) {
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    final targetBase = baseSectionName.toLowerCase().trim();
    int count = 0;
    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        if (_getBaseSectionName(effectiveSec).toLowerCase() == targetBase &&
            !_isOrDuplicateSection(effectiveSec)) {
          count++;
        }
      }
    }
    return count > 0 ? count : _getSectionQuestionCount(baseSectionName);
  }

  int _getOrDuplicateQuestionCount(String baseSectionName) {
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    final targetBase = baseSectionName.toLowerCase().trim();
    int count = 0;
    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        if (_getBaseSectionName(effectiveSec).toLowerCase() == targetBase &&
            _isOrDuplicateSection(effectiveSec)) {
          count++;
        }
      }
    }
    return count;
  }

  void _updateSectionMarks(String baseSectionName, int newMarks) {
    final validated = newMarks < 1 ? 1 : newMarks;
    _recordPreEditSnapshot();
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    final targetBase = baseSectionName.toLowerCase().trim();

    // 1. Update questions in this base section AND its OR duplicate section
    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        if (_getBaseSectionName(effectiveSec).toLowerCase() == targetBase) {
          q['marks'] = validated;
        }
      }
    }

    // 2. Update paper content sections config
    if (_editablePaper['content'] is Map &&
        _editablePaper['content']['sections'] is List) {
      for (final sec in _editablePaper['content']['sections']) {
        if (sec is Map) {
          final sName = (sec['name'] ?? sec['title'] ?? '').toString().trim();
          if (_getBaseSectionName(sName).toLowerCase() == targetBase) {
            sec['marks_per_question'] = validated;
            if (sec['questions'] is List) {
              for (final sq in sec['questions']) {
                if (sq is Map) sq['marks'] = validated;
              }
            }
          }
        }
      }
    }
    _recalculateTotalMarks();
  }

  void _updateSectionName(String oldBaseName, String newBaseName) {
    final trimmed = newBaseName.trim();
    if (trimmed.isEmpty || trimmed == oldBaseName) return;
    _recordPreEditSnapshot();
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];
    final oldTargetBase = oldBaseName.toLowerCase().trim();

    for (final q in questions) {
      if (q is Map) {
        final sec = (q['section_name'] ?? 'Section A').toString().trim();
        final effectiveSec = sec.isEmpty ? 'Section A' : sec;
        if (_getBaseSectionName(effectiveSec).toLowerCase() == oldTargetBase) {
          if (_isOrDuplicateSection(effectiveSec)) {
            q['section_name'] = '$trimmed (OR)';
          } else {
            q['section_name'] = trimmed;
          }
        }
      }
    }
    if (_editablePaper['content'] is Map &&
        _editablePaper['content']['sections'] is List) {
      for (final sec in _editablePaper['content']['sections']) {
        if (sec is Map) {
          final sName = (sec['name'] ?? sec['title'] ?? '').toString().trim();
          if (_getBaseSectionName(sName).toLowerCase() == oldTargetBase) {
            if (_isOrDuplicateSection(sName)) {
              sec['name'] = '$trimmed (OR)';
              sec['title'] = '$trimmed (OR)';
            } else {
              sec['name'] = trimmed;
              sec['title'] = trimmed;
            }
          }
        }
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _preEditDebounce?.cancel();
    _titleCtrl.removeListener(_notifyEdit);
    _classCtrl.removeListener(_notifyEdit);
    _timeCtrl.removeListener(_notifyEdit);
    _titleCtrl.dispose();
    _classCtrl.dispose();
    _timeCtrl.dispose();
    super.dispose();
  }

  _PaperEditorSnapshot _takeSnapshot() {
    return _PaperEditorSnapshot(
      paper: _cloneMap(_editablePaper),
      title: _titleCtrl.text,
      className: _classCtrl.text,
      time: _timeCtrl.text,
    );
  }

  bool _isSnapshotEqual(_PaperEditorSnapshot a, _PaperEditorSnapshot b) {
    if (a.title != b.title || a.className != b.className || a.time != b.time) {
      return false;
    }
    return jsonEncode(a.paper) == jsonEncode(b.paper);
  }

  bool get _hasUnsavedChanges {
    // If no edits were recorded in the undo stack, there are definitely no unsaved changes
    if (_undoStack.isEmpty) return false;
    return !_isSnapshotEqual(_takeSnapshot(), _initialSnapshot);
  }

  void _recordPreEditSnapshot() {
    if (_isApplyingSnapshot) return;
    final current = _takeSnapshot();
    if (_undoStack.isEmpty || !_isSnapshotEqual(_undoStack.last, current)) {
      _undoStack.add(current);
      if (_undoStack.length > 40) {
        _undoStack.removeAt(0);
      }
      _redoStack.clear();
      if (mounted) setState(() {});
    }
  }

  void _notifyEdit() {
    if (_isApplyingSnapshot) return;
    if (!_hasPendingPreEditSnapshot) {
      _recordPreEditSnapshot();
      _hasPendingPreEditSnapshot = true;
    }
    _preEditDebounce?.cancel();
    _preEditDebounce = Timer(const Duration(milliseconds: 600), () {
      _hasPendingPreEditSnapshot = false;
      if (mounted) setState(() {});
    });
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(_takeSnapshot());
    final prev = _undoStack.removeLast();
    _applySnapshot(prev);
  }

  void _redo() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(_takeSnapshot());
    final next = _redoStack.removeLast();
    _applySnapshot(next);
  }

  void _applySnapshot(_PaperEditorSnapshot snapshot) {
    _isApplyingSnapshot = true;
    _hasPendingPreEditSnapshot = false;
    _preEditDebounce?.cancel();
    setState(() {
      _editablePaper = _cloneMap(snapshot.paper);
      _titleCtrl.text = snapshot.title;
      _classCtrl.text = snapshot.className;
      _timeCtrl.text = snapshot.time;
      _editRevision++;
      _recalculateTotalMarks();
    });
    _isApplyingSnapshot = false;
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasUnsavedChanges) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Discard Changes?',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AuthTheme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Are you sure you want to go back? Your edits will be discarded.',
                  style: TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AuthTheme.textSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: AuthPrimaryButton(
                        text: 'Keep Editing',
                        isSecondary: true,
                        height: 44,
                        onPressed: () => Navigator.pop(ctx, false),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AuthPrimaryButton(
                        text: 'Discard',
                        height: 44,
                        isDestructive: true,
                        onPressed: () => Navigator.pop(ctx, true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return discard ?? false;
  }

  Map<String, dynamic> _cloneMap(Map<dynamic, dynamic> map) {
    try {
      return jsonDecode(jsonEncode(map)) as Map<String, dynamic>;
    } catch (_) {
      final Map<String, dynamic> cloned = {};
      map.forEach((key, value) {
        if (value is Map) {
          cloned[key.toString()] = _cloneMap(value);
        } else if (value is List) {
          cloned[key.toString()] = _cloneList(value);
        } else {
          cloned[key.toString()] = value;
        }
      });
      return cloned;
    }
  }

  List<dynamic> _cloneList(List<dynamic> list) {
    final List<dynamic> cloned = [];
    for (var item in list) {
      if (item is Map) {
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
      final sec = (q['section_name'] ?? '').toString().trim();
      // Skip duplicate OR sections so their marks are not double-counted
      if (_isOrDuplicateSection(sec)) {
        continue;
      }

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

  Future<void> _handleBack() async {
    if (!_hasUnsavedChanges) {
      Navigator.pop(context);
      return;
    }
    final shouldPop = await _confirmDiscard();
    if (shouldPop && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = _editablePaper['questions'] as List<dynamic>? ?? [];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges) {
          Navigator.pop(context);
          return;
        }
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) {
          final vx = details.primaryVelocity ?? 0;
          if (vx > 250 || vx < -250) {
            _handleBack();
          }
        },
        child: Scaffold(
          backgroundColor: WorkspaceTheme.canvas,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Top Modern Header (Full width stretching to both walls)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
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
                      // Back Navigation Button (Always visible)
                      Tooltip(
                        message: 'Back',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _handleBack,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                size: 18,
                                color: AuthTheme.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

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

                      // Undo Button
                      Tooltip(
                        message: _undoStack.isNotEmpty
                            ? 'Undo'
                            : 'Nothing to undo',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _undoStack.isNotEmpty ? _undo : null,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _undoStack.isNotEmpty
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _undoStack.isNotEmpty
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Icon(
                                Icons.undo_rounded,
                                size: 18,
                                color: _undoStack.isNotEmpty
                                    ? AuthTheme.textPrimary
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Redo Button
                      Tooltip(
                        message: _redoStack.isNotEmpty
                            ? 'Redo'
                            : 'Nothing to redo',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _redoStack.isNotEmpty ? _redo : null,
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _redoStack.isNotEmpty
                                    ? const Color(0xFFF1F5F9)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _redoStack.isNotEmpty
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Icon(
                                Icons.redo_rounded,
                                size: 18,
                                color: _redoStack.isNotEmpty
                                    ? AuthTheme.textPrimary
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),

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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 18,
                        ),
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
                                borderRadius: BorderRadius.circular(
                                  AuthTheme.radiusCard,
                                ),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
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
                                          hintText: 'e.g. 90',
                                          icon: Icons.timer_outlined,
                                          isNumber: true,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  const Divider(
                                    height: 1,
                                    color: Color(0xFFF1F5F9),
                                  ),
                                  const SizedBox(height: 16),

                                  // Sections & Marks per Section Header
                                  Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEFF6FF),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.view_agenda_outlined,
                                          color: Color(0xFF2563EB),
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sections & Marks Allocation',
                                              style: TextStyle(
                                                fontFamily:
                                                    AuthTheme.fontFamily,
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w700,
                                                color: AuthTheme.textPrimary,
                                              ),
                                            ),
                                            SizedBox(height: 2),
                                            Text(
                                              'Marks apply across all questions in each section.',
                                              style: TextStyle(
                                                fontFamily:
                                                    AuthTheme.fontFamily,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                                color: AuthTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),

                                  // Section rows
                                  ..._getDistinctSectionNames().map((secName) {
                                    final currentMarks = _getSectionMarks(
                                      secName,
                                    );
                                    final hasOr =
                                        _sectionHasOrDuplicate(secName);
                                    final primaryCount =
                                        _getPrimarySectionQuestionCount(secName);
                                    final orCount =
                                        _getOrDuplicateQuestionCount(secName);
                                    final totalCount =
                                        _getSectionQuestionCount(secName);

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: hasOr
                                              ? AuthTheme.accentSky
                                                  .withValues(alpha: 0.35)
                                              : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (hasOr) ...[
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: AuthTheme.accentSky
                                                        .withValues(alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                  ),
                                                  child: const Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        Icons.call_split_rounded,
                                                        size: 11,
                                                        color:
                                                            AuthTheme.accentSky,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'Merged with OR Alternate Section',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              AuthTheme.fontFamily,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              AuthTheme.accentSky,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              // Section Name Field
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Section Name',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AuthTheme.fontFamily,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color:
                                                            AuthTheme.textSecondary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    TextFormField(
                                                      key: ValueKey(
                                                        'sec_name_${secName}_$_editRevision',
                                                      ),
                                                      initialValue: secName,
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            AuthTheme.fontFamily,
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                      decoration: InputDecoration(
                                                        isDense: true,
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        contentPadding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 8,
                                                            ),
                                                        border: OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                8,
                                                              ),
                                                          borderSide:
                                                              const BorderSide(
                                                                color: Color(
                                                                  0xFFE2E8F0,
                                                                ),
                                                              ),
                                                        ),
                                                        enabledBorder:
                                                            OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              borderSide:
                                                                  const BorderSide(
                                                                    color: Color(
                                                                      0xFFE2E8F0,
                                                                    ),
                                                                  ),
                                                            ),
                                                      ),
                                                      onChanged: (newVal) =>
                                                          _updateSectionName(
                                                            secName,
                                                            newVal,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              // Marks per Question Field
                                              Expanded(
                                                flex: 2,
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Marks / Q',
                                                      style: TextStyle(
                                                        fontFamily:
                                                            AuthTheme.fontFamily,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w600,
                                                        color:
                                                            AuthTheme.textSecondary,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    _QuestionMarksField(
                                                      key: ValueKey(
                                                        'sec_marks_${secName}_${currentMarks}_$_editRevision',
                                                      ),
                                                      initialMarks: currentMarks,
                                                      showLabel: false,
                                                      onChanged: (newMarks) =>
                                                          _updateSectionMarks(
                                                            secName,
                                                            newMarks,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              // Question Count & Subtotal
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: const Color(0xFFE2E8F0),
                                                  ),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      hasOr && orCount > 0
                                                          ? '$primaryCount Qs (+ $orCount OR)'
                                                          : '$totalCount Qs',
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            AuthTheme.fontFamily,
                                                        fontSize: 11,
                                                        fontWeight: FontWeight.w700,
                                                        color:
                                                            AuthTheme.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${primaryCount * currentMarks} marks',
                                                      style: const TextStyle(
                                                        fontFamily:
                                                            AuthTheme.fontFamily,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w500,
                                                        color:
                                                            AuthTheme.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
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
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            color: AuthTheme.primary.withValues(
                                              alpha: 0.8,
                                            ),
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(
                                      AuthTheme.radiusPill,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
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
                                return _buildQuestionCard(
                                  questions[index],
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
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
          inputFormatters: isNumber
              ? [FilteringTextInputFormatter.digitsOnly]
              : null,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
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
              borderSide: const BorderSide(
                color: AuthTheme.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question, int index) {
    final rawText =
        question['question_text'] ?? question['question'] ?? 'Empty Question';
    final qText = TextSanitizer.cleanLaTeX(rawText.toString());
    final previewText = qText.length > 50
        ? '${qText.substring(0, 50)}...'
        : qText;
    final rawMarks = (question['marks'] as num?)?.toInt() ?? 1;
    final marks = rawMarks < 1 ? 1 : rawMarks;
    final section = (question['section_name'] ?? '').toString();

    final List<dynamic> opts =
        question['mcq_options'] ?? question['options'] ?? [];
    final bool isMcq = opts.isNotEmpty;

    return Container(
      key: ValueKey('q_${index}_$_editRevision'),
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
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF2F8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.hub_outlined,
                            size: 10,
                            color: Color(0xFFDB2777),
                          ),
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
                initialValue:
                    (question['question_text'] ?? question['question'] ?? '')
                        .toString(),
                maxLines: null,
                onChanged: (val) {
                  _notifyEdit();
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
                              _notifyEdit();
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
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE2E8F0),
                                ),
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
  final bool showLabel;

  const _QuestionMarksField({
    super.key,
    required this.initialMarks,
    required this.onChanged,
    this.showLabel = true,
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
  void didUpdateWidget(_QuestionMarksField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMarks != oldWidget.initialMarks) {
      final currentText = _controller.text;
      if (currentText != widget.initialMarks.toString()) {
        _controller.text = widget.initialMarks.toString();
      }
    }
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
        if (widget.showLabel) ...[
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
        ],
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: true,
          ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 12,
                  color: AuthTheme.error,
                ),
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
