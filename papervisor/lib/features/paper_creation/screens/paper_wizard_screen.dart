import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../services/book_service.dart';
import '../../../../services/chapter_service.dart';
import '../models/paper_wizard_state.dart';
import 'paper_wizard_step_marks.dart';

class PaperWizardScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  const PaperWizardScreen({Key? key, required this.subject}) : super(key: key);

  @override
  State<PaperWizardScreen> createState() => _PaperWizardScreenState();
}

class _PaperWizardScreenState extends State<PaperWizardScreen> {
  final BookService _bookService = BookService();
  final ChapterService _chapterService = ChapterService();
  final PaperWizardState _state = PaperWizardState();

  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _chapters = [];
  bool _loadingBooks = true;
  bool _loadingChapters = false;
  String? _bookError;

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final list = await _bookService.getBooks(widget.subject['id']);
      if (mounted) setState(() { _books = list; _loadingBooks = false; });
    } catch (e) {
      if (mounted) setState(() { _bookError = e.toString().replaceAll('Exception: ', ''); _loadingBooks = false; });
    }
  }

  static const List<Color> _palette = [
    Color(0xFF534BDE), // AppColors.primary
    Color(0xFF0EA5E9), // Sky Blue
    Color(0xFF10B981), // Emerald
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF14B8A6), // Teal
    Color(0xFFF97316), // Orange
    Color(0xFF06B6D4), // Cyan
    Color(0xFF6366F1), // Indigo light
  ];

  Future<void> _fetchChapters(String bookId) async {
    setState(() {
      _loadingChapters = true;
      _chapters = [];
      _state.selectedChapterIds = [];
      _state.chapterWeightages.clear();
    });
    try {
      final list = await _chapterService.getChapters(bookId);
      if (mounted) setState(() { _chapters = list; _loadingChapters = false; });
    } catch (_) {
      if (mounted) setState(() { _loadingChapters = false; });
    }
  }

  bool get _canContinue {
    if (_state.bookId == null || _state.selectedChapterIds.isEmpty) return false;
    if (_state.enableChapterWeightage) {
      return _state.totalChapterWeightage == 100;
    }
    return true;
  }

  void _openWeightageSheet({String? focusChapterId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final selectedChapters = _chapters.where(
              (c) => _state.selectedChapterIds.contains(c['id']),
            ).toList();
            final total = _state.totalChapterWeightage;
            final isExact100 = total == 100;

            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle drag pill
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.divider,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chapter Weightage',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Adjust percentages to total 100%',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Total & Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isExact100
                            ? AppColors.success.withOpacity(0.08)
                            : AppColors.warning.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isExact100
                              ? AppColors.success.withOpacity(0.3)
                              : AppColors.warning.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isExact100 ? Icons.check_circle : Icons.warning_amber_rounded,
                                size: 18,
                                color: isExact100 ? AppColors.success : AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Total Weightage: $total%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isExact100 ? AppColors.success : AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.restart_alt, size: 14, color: AppColors.primary),
                            label: const Text(
                              'Equalize',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            onPressed: () {
                              setModalState(() {
                                _state.recalculateDefaultWeightages();
                              });
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Segmented Visual Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        height: 10,
                        child: Row(
                          children: selectedChapters.map((ch) {
                            final chId = ch['id'] as String;
                            final idx = _state.selectedChapterIds.indexOf(chId);
                            final color = _palette[idx % _palette.length];
                            final weight = _state.chapterWeightages[chId] ?? 0;
                            return Expanded(
                              flex: weight.clamp(0, 100),
                              child: Container(color: color),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scrollable list of chapters
                    Expanded(
                      child: ListView.separated(
                        itemCount: selectedChapters.length,
                        separatorBuilder: (_, _) => const Divider(height: 16),
                        itemBuilder: (context, index) {
                          final chapter = selectedChapters[index];
                          final chId = chapter['id'] as String;
                          final color = _palette[index % _palette.length];
                          final weight = _state.chapterWeightages[chId] ?? 0;
                          final isFocused = focusChapterId == chId;

                          return Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isFocused ? color.withOpacity(0.06) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    Expanded(
                                      child: Text(
                                        chapter['name'] ?? chapter['title'] ?? 'Chapter',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$weight%',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: color,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 22),
                                      color: weight > 0 ? AppColors.textSecondary : AppColors.divider,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: weight > 0
                                          ? () {
                                              setModalState(() {
                                                _state.updateChapterWeightage(chId, weight - 5 < 0 ? 0 : weight - 5);
                                              });
                                              setState(() {});
                                            }
                                          : null,
                                    ),
                                    Expanded(
                                      child: SliderTheme(
                                        data: SliderTheme.of(context).copyWith(
                                          activeTrackColor: color,
                                          thumbColor: color,
                                          overlayColor: color.withOpacity(0.15),
                                          trackHeight: 4,
                                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                        ),
                                        child: Slider(
                                          value: weight.toDouble().clamp(0.0, 100.0),
                                          min: 0,
                                          max: 100,
                                          divisions: 100,
                                          onChanged: (val) {
                                            setModalState(() {
                                              _state.updateChapterWeightage(chId, val.round());
                                            });
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 22),
                                      color: weight < 100 ? AppColors.textSecondary : AppColors.divider,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                                      onPressed: weight < 100
                                          ? () {
                                              setModalState(() {
                                                _state.updateChapterWeightage(chId, weight + 5 > 100 ? 100 : weight + 5);
                                              });
                                              setState(() {});
                                            }
                                          : null,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Done Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(bottomSheetContext),
                        child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Step 1 of 5', style: theme.textTheme.bodySmall),
          Text('Book & Chapters', style: theme.textTheme.titleLarge),
        ]),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(0),
            Expanded(
              child: _loadingBooks
                  ? const Center(child: CircularProgressIndicator())
                  : _bookError != null
                      ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(_bookError!, style: const TextStyle(color: AppColors.error)),
                          const SizedBox(height: 16),
                          ElevatedButton(onPressed: _fetchBooks, child: const Text('Retry')),
                        ]))
                      : _books.isEmpty
                          ? const Center(child: Text('No books found in this subject.', style: TextStyle(color: AppColors.textSecondary)))
                          : SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text('CHOOSE BOOK', style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2)),
                                const SizedBox(height: 16),
                                ..._books.map((book) {
                                  final isSelected = _state.bookId == book['id'];
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() { _state.bookId = book['id']; });
                                      _fetchChapters(book['id']);
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected ? AppColors.primary : AppColors.divider,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(children: [
                                        CircleAvatar(
                                          backgroundColor: isSelected ? AppColors.primaryLight.withOpacity(0.1) : AppColors.background,
                                          child: Icon(Icons.menu_book, color: isSelected ? AppColors.primary : AppColors.textSecondary),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(child: Text(
                                          book['name'] ?? book['title'] ?? 'Book',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isSelected ? AppColors.primary : AppColors.textPrimary),
                                        )),
                                        if (isSelected) const Icon(Icons.check_circle_outline, color: AppColors.primary),
                                      ]),
                                    ),
                                  );
                                }),

                                if (_state.bookId != null) ...[
                                  const SizedBox(height: 32),
                                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                    Text('CHOOSE CHAPTERS', style: theme.textTheme.labelLarge?.copyWith(fontSize: 12, letterSpacing: 1.2)),
                                    if (!_loadingChapters && _chapters.isNotEmpty)
                                      TextButton(
                                        onPressed: () => setState(() {
                                          if (_state.selectedChapterIds.length == _chapters.length) {
                                            _state.selectedChapterIds = [];
                                            _state.chapterWeightages.clear();
                                          } else {
                                            _state.selectedChapterIds = _chapters.map((c) => c['id'] as String).toList();
                                            if (_state.enableChapterWeightage) {
                                              _state.recalculateDefaultWeightages();
                                            }
                                          }
                                        }),
                                        child: Text(
                                          _state.selectedChapterIds.length == _chapters.length ? 'Deselect All' : 'Select All',
                                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                  ]),

                                  // Chapter Weightage Toggle Card
                                  if (!_loadingChapters && _chapters.isNotEmpty) ...[
                                    Container(
                                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: _state.enableChapterWeightage
                                            ? AppColors.primaryLight.withOpacity(0.06)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: _state.enableChapterWeightage
                                              ? AppColors.primary.withOpacity(0.4)
                                              : AppColors.divider,
                                          width: _state.enableChapterWeightage ? 1.5 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: _state.enableChapterWeightage
                                                      ? AppColors.primary
                                                      : AppColors.background,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Icon(
                                                  Icons.pie_chart_outline_rounded,
                                                  color: _state.enableChapterWeightage
                                                      ? Colors.white
                                                      : AppColors.textSecondary,
                                                  size: 20,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    const Text(
                                                      'Chapter Weightage',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 14,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                    Text(
                                                      _state.enableChapterWeightage
                                                          ? 'Custom percentage per chapter'
                                                          : 'Disabled (Weightage not applied)',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Switch(
                                                value: _state.enableChapterWeightage,
                                                activeColor: AppColors.primary,
                                                onChanged: (val) {
                                                  setState(() {
                                                    _state.enableChapterWeightage = val;
                                                    if (val && _state.selectedChapterIds.isNotEmpty) {
                                                      _state.recalculateDefaultWeightages();
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                          if (_state.enableChapterWeightage && _state.selectedChapterIds.isNotEmpty) ...[
                                            const Divider(height: 20),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      _state.totalChapterWeightage == 100
                                                          ? Icons.check_circle
                                                          : Icons.warning_amber_rounded,
                                                      size: 16,
                                                      color: _state.totalChapterWeightage == 100
                                                          ? AppColors.success
                                                          : AppColors.warning,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      'Total: ${_state.totalChapterWeightage}%',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                        color: _state.totalChapterWeightage == 100
                                                          ? AppColors.success
                                                          : AppColors.warning,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    TextButton.icon(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        minimumSize: Size.zero,
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      ),
                                                      icon: const Icon(Icons.tune, size: 14, color: AppColors.primary),
                                                      label: const Text('Adjust All', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                                      onPressed: () => _openWeightageSheet(),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    TextButton.icon(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                        minimumSize: Size.zero,
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      ),
                                                      icon: const Icon(Icons.restart_alt, size: 14, color: AppColors.textSecondary),
                                                      label: const Text('Equalize', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                                      onPressed: () {
                                                        setState(() {
                                                          _state.recalculateDefaultWeightages();
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 8),
                                  if (_loadingChapters)
                                    const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()))
                                  else
                                    ..._chapters.map((chapter) {
                                      final chapterId = chapter['id'] as String;
                                      final isSelected = _state.selectedChapterIds.contains(chapterId);
                                      final weightage = _state.chapterWeightages[chapterId] ?? 0;

                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: isSelected ? AppColors.primaryLight.withOpacity(0.05) : Colors.transparent,
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected ? AppColors.primary : AppColors.divider,
                                            width: isSelected ? 1.5 : 1,
                                          ),
                                        ),
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(16),
                                          onTap: () => setState(() {
                                            if (isSelected) {
                                              _state.selectedChapterIds.remove(chapterId);
                                              _state.chapterWeightages.remove(chapterId);
                                              if (_state.enableChapterWeightage) {
                                                _state.recalculateDefaultWeightages();
                                              }
                                            } else {
                                              _state.selectedChapterIds.add(chapterId);
                                              if (_state.enableChapterWeightage) {
                                                _state.recalculateDefaultWeightages();
                                              }
                                            }
                                          }),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isSelected ? Icons.check_circle : Icons.check_circle_outline,
                                                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                                                ),
                                                const SizedBox(width: 14),
                                                Expanded(
                                                  child: Text(
                                                    chapter['name'] ?? chapter['title'] ?? 'Chapter',
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14,
                                                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                // % button side of the chapter name
                                                if (_state.enableChapterWeightage && isSelected) ...[
                                                  const SizedBox(width: 8),
                                                  GestureDetector(
                                                    behavior: HitTestBehavior.opaque,
                                                    onTap: () => _openWeightageSheet(focusChapterId: chapterId),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary.withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            '$weightage%',
                                                            style: const TextStyle(
                                                              color: AppColors.primary,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 4),
                                                          const Icon(Icons.tune, size: 13, color: AppColors.primary),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                  }),
                                ],
                              ]),
                            ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_state.enableChapterWeightage &&
                      _state.selectedChapterIds.isNotEmpty &&
                      _state.totalChapterWeightage != 100)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Total weightage must equal 100% to continue',
                        style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  PrimaryButton(
                    text: 'Continue',
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _canContinue ? () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => PaperWizardStepMarks(subject: widget.subject, state: _state),
                      ));
                    } : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int activeUpTo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(children: List.generate(5, (i) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: i == 4 ? 0 : 8),
          height: 4,
          decoration: BoxDecoration(
            color: i <= activeUpTo ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ))),
    );
  }
}
