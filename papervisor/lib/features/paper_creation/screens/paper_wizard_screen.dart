import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../auth/theme/auth_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../../services/book_service.dart';
import '../../../../services/chapter_service.dart';
import '../models/paper_wizard_state.dart';
import '../widgets/wizard_bottom_bar.dart';
import '../widgets/wizard_step_header.dart';
import 'paper_wizard_step_marks.dart';

class PaperWizardScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final String? initialBookId;

  const PaperWizardScreen({
    super.key,
    required this.subject,
    this.initialBookId,
  });

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
    if (widget.initialBookId != null) {
      _state.bookId = widget.initialBookId;
      _fetchChapters(widget.initialBookId!);
    }
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final list = await _bookService.getBooks(widget.subject['id']);
      if (mounted) {
        setState(() {
          _books = list;
          _loadingBooks = false;
          if (widget.initialBookId != null && _state.bookId == null) {
            _state.bookId = widget.initialBookId;
            _fetchChapters(widget.initialBookId!);
          }
        });
      }
    } catch (e) {
      if (mounted)
        setState(() {
          _bookError = e.toString().replaceAll('Exception: ', '');
          _loadingBooks = false;
        });
    }
  }

  Future<void> _fetchChapters(String bookId) async {
    setState(() {
      _loadingChapters = true;
      _chapters = [];
      _state.selectedChapterIds = [];
      _state.chapterWeightages.clear();
    });
    try {
      final list = await _chapterService.getChapters(bookId);
      if (mounted)
        setState(() {
          _chapters = list;
          _loadingChapters = false;
        });
    } catch (_) {
      if (mounted)
        setState(() {
          _loadingChapters = false;
        });
    }
  }

  bool get _canContinue {
    if (_state.bookId == null || _state.selectedChapterIds.isEmpty)
      return false;
    if (_state.enableChapterWeightage) {
      return _state.totalChapterWeightage == 100;
    }
    return true;
  }

  void _openWeightageSheet({String? focusChapterId}) {
    AdaptiveModal.show(
      context: context,
      maxWidth: 540,
      builder: (modalContext, isDialog) {
        return Container(
          decoration: BoxDecoration(
            color: WorkspaceTheme.surfaceWhite,
            borderRadius: isDialog
                ? BorderRadius.circular(24)
                : const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final selectedChapters = _chapters
                  .where((c) => _state.selectedChapterIds.contains(c['id']))
                  .toList();
              final total = _state.totalChapterWeightage;
              final isExact100 = total == 100;

              return SafeArea(
                top: false,
                bottom: !isDialog,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height *
                        (isDialog ? 0.82 : 0.85),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    isDialog ? 20 : 12,
                    20,
                    isDialog
                        ? 20
                        : MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isDialog) ...[
                        // Drag handle
                        Center(
                          child: Container(
                            width: 36,
                            height: 4,
                            decoration: BoxDecoration(
                              color: WorkspaceTheme.borderMedium,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Title and Quick Balance action
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chapter Weightage',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: WorkspaceTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Target total weightage: 100%',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 12,
                                  color: WorkspaceTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  backgroundColor: WorkspaceTheme.surfaceMuted,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: Icon(
                                  Icons.restart_alt_rounded,
                                  size: 16,
                                  color: WorkspaceTheme.textSecondary,
                                ),
                                label: Text(
                                  'Equalize',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: WorkspaceTheme.textSecondary,
                                  ),
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    _state.recalculateDefaultWeightages();
                                  });
                                  setState(() {});
                                },
                              ),
                              if (isDialog) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => Navigator.pop(modalContext),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 20,
                                    color: WorkspaceTheme.textSecondary,
                                  ),
                                  splashRadius: 18,
                                  tooltip: 'Close',
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Total Weightage Indicator Bar
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isExact100
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isExact100
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isExact100
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              color: isExact100
                                  ? AuthTheme.success
                                  : const Color(0xFFD97706),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isExact100
                                    ? 'Total: 100% (Balanced)'
                                    : 'Total: $total% (Needs ${100 - total > 0 ? "+${100 - total}%" : "${100 - total}%"})',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isExact100
                                      ? AuthTheme.success
                                      : const Color(0xFFD97706),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Chapters List with Stepper / Slider
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: selectedChapters.length,
                          itemBuilder: (context, i) {
                            final ch = selectedChapters[i];
                            final chId = ch['id'] as String;
                            final currentWeight =
                                _state.chapterWeightages[chId] ?? 0;
                            final chNum = (ch['chapter_number'] ?? (i + 1))
                                .toString();
                            final formattedNum = chNum.length == 1
                                ? '0$chNum'
                                : chNum;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: WorkspaceTheme.surfaceSubtle,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: focusChapterId == chId
                                      ? WorkspaceTheme.accentCobalt
                                      : WorkspaceTheme.borderSubtle,
                                  width: focusChapterId == chId ? 1.5 : 1.0,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: WorkspaceTheme.accentLight,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          formattedNum,
                                          style: TextStyle(
                                            fontFamily: AuthTheme.fontFamily,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: WorkspaceTheme.accentCobalt,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          ch['name'] ??
                                              ch['title'] ??
                                              'Chapter',
                                          style: TextStyle(
                                            fontFamily: AuthTheme.fontFamily,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: WorkspaceTheme.textPrimary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Decrement Button (-5%)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline_rounded,
                                          size: 20,
                                        ),
                                        color: currentWeight > 0
                                            ? WorkspaceTheme.textPrimary
                                            : WorkspaceTheme.borderMedium,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        onPressed: currentWeight > 0
                                            ? () {
                                                setModalState(() {
                                                  _state.updateChapterWeightage(
                                                    chId,
                                                    currentWeight - 5 < 0
                                                        ? 0
                                                        : currentWeight - 5,
                                                  );
                                                });
                                                setState(() {});
                                              }
                                            : null,
                                      ),

                                      // Value Display
                                      Container(
                                        constraints: const BoxConstraints(
                                          minWidth: 46,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$currentWeight%',
                                          style: TextStyle(
                                            fontFamily: AuthTheme.fontFamily,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: WorkspaceTheme.accentCobalt,
                                          ),
                                        ),
                                      ),

                                      // Increment Button (+5%)
                                      IconButton(
                                        icon: const Icon(
                                          Icons.add_circle_outline_rounded,
                                          size: 20,
                                        ),
                                        color: currentWeight < 100
                                            ? WorkspaceTheme.accentCobalt
                                            : WorkspaceTheme.borderMedium,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                        onPressed: currentWeight < 100
                                            ? () {
                                                setModalState(() {
                                                  _state.updateChapterWeightage(
                                                    chId,
                                                    currentWeight + 5 > 100
                                                        ? 100
                                                        : currentWeight + 5,
                                                  );
                                                });
                                                setState(() {});
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                  SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      activeTrackColor:
                                          WorkspaceTheme.accentCobalt,
                                      inactiveTrackColor:
                                          WorkspaceTheme.borderSubtle,
                                      thumbColor: WorkspaceTheme.accentCobalt,
                                      overlayColor: WorkspaceTheme.accentCobalt
                                          .withValues(alpha: 0.15),
                                      trackHeight: 3,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 6,
                                      ),
                                    ),
                                    child: Slider(
                                      value: currentWeight.toDouble().clamp(
                                        0.0,
                                        100.0,
                                      ),
                                      min: 0,
                                      max: 100,
                                      divisions: 100,
                                      onChanged: (val) {
                                        setModalState(() {
                                          _state.updateChapterWeightage(
                                            chId,
                                            val.round(),
                                          );
                                        });
                                        setState(() {});
                                      },
                                    ),
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
                            backgroundColor: WorkspaceTheme.accentCobalt,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AuthTheme.radiusPill,
                              ),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => Navigator.pop(modalContext),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    return Scaffold(
      backgroundColor: WorkspaceTheme.canvas,
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
                  currentStep: 1,
                  title: 'Select Chapters',
                  subtitle: 'Choose the source book and chapters for questions',
                  onBack: () => Navigator.pop(context),
                ),

                // Main Content Area
                Expanded(
                  child: _loadingBooks
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AuthTheme.primary,
                          ),
                        )
                      : _bookError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AuthTheme.error,
                                  size: 40,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _bookError!,
                                  style: const TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    color: AuthTheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AuthTheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _fetchBooks,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _books.isEmpty
                      ? const Center(
                          child: Text(
                            'No books found in this subject.',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              color: AuthTheme.textSecondary,
                            ),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Books Section Title
                              Text(
                                'SELECT BOOK',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: WorkspaceTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Books Cards List
                              ..._books.map((book) {
                                final isSelected = _state.bookId == book['id'];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: WorkspaceTheme.surfaceWhite,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? WorkspaceTheme.accentCobalt
                                          : WorkspaceTheme.borderSubtle,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? AuthTheme.primary.withValues(
                                                alpha: 0.08,
                                              )
                                            : Colors.black.withValues(
                                                alpha: 0.02,
                                              ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(16),
                                      onTap: () {
                                        setState(() {
                                          _state.bookId = book['id'];
                                        });
                                        _fetchChapters(book['id']);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(14.0),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? const Color(0xFF0284C7)
                                                    : const Color(0xFFEFF6FF),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFF0284C7)
                                                      : const Color(0xFFBAE6FD),
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.menu_book_rounded,
                                                color: isSelected
                                                    ? Colors.white
                                                    : AuthTheme.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    book['name'] ??
                                                        book['title'] ??
                                                        'Book',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AuthTheme.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 15,
                                                      color: isSelected
                                                          ? WorkspaceTheme
                                                                .accentCobalt
                                                          : WorkspaceTheme
                                                                .textPrimary,
                                                      letterSpacing: -0.2,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Source textbook for exam questions',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AuthTheme.fontFamily,
                                                      fontSize: 11,
                                                      color: WorkspaceTheme
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (isSelected)
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: const BoxDecoration(
                                                  color: AuthTheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.check_rounded,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                              )
                                            else
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFCBD5E1,
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
                              }),

                              // Chapters Section
                              if (_state.bookId != null) ...[
                                const SizedBox(height: 24),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'CHOOSE CHAPTERS',
                                      style: TextStyle(
                                        fontFamily: AuthTheme.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.1,
                                        color: WorkspaceTheme.textSecondary,
                                      ),
                                    ),
                                    if (!_loadingChapters &&
                                        _chapters.isNotEmpty)
                                      TextButton(
                                        onPressed: () => setState(() {
                                          if (_state
                                                  .selectedChapterIds
                                                  .length ==
                                              _chapters.length) {
                                            _state.selectedChapterIds = [];
                                            _state.chapterWeightages.clear();
                                          } else {
                                            _state
                                                .selectedChapterIds = _chapters
                                                .map((c) => c['id'] as String)
                                                .toList();
                                            if (_state.enableChapterWeightage) {
                                              _state
                                                  .recalculateDefaultWeightages();
                                            }
                                          }
                                        }),
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                        ),
                                        child: Text(
                                          _state.selectedChapterIds.length ==
                                                  _chapters.length
                                              ? 'Deselect All'
                                              : 'Select All',
                                          style: TextStyle(
                                            fontFamily: AuthTheme.fontFamily,
                                            color: WorkspaceTheme.accentCobalt,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),

                                // Chapter Weightage Card
                                if (!_loadingChapters &&
                                    _chapters.isNotEmpty) ...[
                                  Container(
                                    margin: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 16,
                                    ),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: WorkspaceTheme.surfaceWhite,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: _state.enableChapterWeightage
                                            ? WorkspaceTheme.accentCobalt
                                                  .withValues(alpha: 0.4)
                                            : WorkspaceTheme.borderSubtle,
                                        width: _state.enableChapterWeightage
                                            ? 1.5
                                            : 1,
                                      ),
                                      boxShadow: WorkspaceTheme.cardShadow,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color:
                                                    _state
                                                        .enableChapterWeightage
                                                    ? WorkspaceTheme.accentLight
                                                    : WorkspaceTheme
                                                          .surfaceMuted,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.pie_chart_outline_rounded,
                                                color:
                                                    _state
                                                        .enableChapterWeightage
                                                    ? WorkspaceTheme
                                                          .accentCobalt
                                                    : WorkspaceTheme
                                                          .textSecondary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Chapter Weightage',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AuthTheme.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 14,
                                                      color: WorkspaceTheme
                                                          .textPrimary,
                                                    ),
                                                  ),
                                                  Text(
                                                    _state.enableChapterWeightage
                                                        ? 'Custom percentage per chapter'
                                                        : 'Distribute questions evenly',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AuthTheme.fontFamily,
                                                      fontSize: 12,
                                                      color: WorkspaceTheme
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Switch(
                                              value:
                                                  _state.enableChapterWeightage,
                                              activeThumbColor:
                                                  WorkspaceTheme.accentCobalt,
                                              activeTrackColor: WorkspaceTheme
                                                  .accentCobalt
                                                  .withValues(alpha: 0.5),
                                              onChanged: (val) {
                                                setState(() {
                                                  _state.enableChapterWeightage =
                                                      val;
                                                  if (val &&
                                                      _state
                                                          .selectedChapterIds
                                                          .isNotEmpty) {
                                                    _state
                                                        .recalculateDefaultWeightages();
                                                  }
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                        if (_state.enableChapterWeightage &&
                                            _state
                                                .selectedChapterIds
                                                .isNotEmpty) ...[
                                          Divider(
                                            height: 20,
                                            color: WorkspaceTheme.borderSubtle,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    _state.totalChapterWeightage ==
                                                            100
                                                        ? Icons
                                                              .check_circle_rounded
                                                        : Icons
                                                              .warning_amber_rounded,
                                                    size: 16,
                                                    color:
                                                        _state.totalChapterWeightage ==
                                                            100
                                                        ? AuthTheme.success
                                                        : const Color(
                                                            0xFFD97706,
                                                          ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Total: ${_state.totalChapterWeightage}%',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AuthTheme.fontFamily,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13,
                                                      color:
                                                          _state.totalChapterWeightage ==
                                                              100
                                                          ? AuthTheme.success
                                                          : const Color(
                                                              0xFFD97706,
                                                            ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    icon: Icon(
                                                      Icons.tune_rounded,
                                                      size: 14,
                                                      color: WorkspaceTheme
                                                          .accentCobalt,
                                                    ),
                                                    label: Text(
                                                      'Adjust All',
                                                      style: TextStyle(
                                                        fontFamily: AuthTheme
                                                            .fontFamily,
                                                        fontSize: 12,
                                                        color: WorkspaceTheme
                                                            .accentCobalt,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                    onPressed: () =>
                                                        _openWeightageSheet(),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  TextButton.icon(
                                                    style: TextButton.styleFrom(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      minimumSize: Size.zero,
                                                      tapTargetSize:
                                                          MaterialTapTargetSize
                                                              .shrinkWrap,
                                                    ),
                                                    icon: Icon(
                                                      Icons.restart_alt_rounded,
                                                      size: 14,
                                                      color: WorkspaceTheme
                                                          .textSecondary,
                                                    ),
                                                    label: Text(
                                                      'Equalize',
                                                      style: TextStyle(
                                                        fontFamily: AuthTheme
                                                            .fontFamily,
                                                        fontSize: 12,
                                                        color: WorkspaceTheme
                                                            .textSecondary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _state
                                                            .recalculateDefaultWeightages();
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

                                const SizedBox(height: 6),
                                if (_loadingChapters)
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final screenH = MediaQuery.of(
                                        context,
                                      ).size.height;
                                      final minH = screenH * 0.38;
                                      return ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minHeight: minH,
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SizedBox(
                                                width: 36,
                                                height: 36,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 3,
                                                      color:
                                                          WorkspaceTheme.isDark
                                                          ? const Color(
                                                              0xFF38BDF8,
                                                            )
                                                          : WorkspaceTheme
                                                                .accentCobalt,
                                                    ),
                                              ),
                                              const SizedBox(height: 14),
                                              Text(
                                                'Loading chapters...',
                                                style: TextStyle(
                                                  fontFamily:
                                                      AuthTheme.fontFamily,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: WorkspaceTheme
                                                      .textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                else
                                  ..._chapters.asMap().entries.map((entry) {
                                    final i = entry.key;
                                    final chapter = entry.value;
                                    final chapterId = chapter['id'] as String;
                                    final isSelected = _state.selectedChapterIds
                                        .contains(chapterId);
                                    final weightage =
                                        _state.chapterWeightages[chapterId] ??
                                        0;
                                    final rawNum =
                                        chapter['chapter_number'] ?? (i + 1);
                                    final formattedNum =
                                        rawNum.toString().length == 1
                                        ? '0$rawNum'
                                        : rawNum.toString();

                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      decoration: BoxDecoration(
                                        color: WorkspaceTheme.surfaceWhite,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSelected
                                              ? WorkspaceTheme.accentCobalt
                                              : WorkspaceTheme.borderSubtle,
                                          width: isSelected ? 1.5 : 1,
                                        ),
                                        boxShadow: WorkspaceTheme.cardShadow,
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          onTap: () => setState(() {
                                            if (isSelected) {
                                              _state.selectedChapterIds.remove(
                                                chapterId,
                                              );
                                              _state.chapterWeightages.remove(
                                                chapterId,
                                              );
                                              if (_state
                                                  .enableChapterWeightage) {
                                                _state
                                                    .recalculateDefaultWeightages();
                                              }
                                            } else {
                                              _state.selectedChapterIds.add(
                                                chapterId,
                                              );
                                              if (_state
                                                  .enableChapterWeightage) {
                                                _state
                                                    .recalculateDefaultWeightages();
                                              }
                                            }
                                          }),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 12,
                                            ),
                                            child: Row(
                                              children: [
                                                // Number Badge
                                                Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? WorkspaceTheme
                                                              .accentLight
                                                        : WorkspaceTheme
                                                              .surfaceMuted,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? WorkspaceTheme
                                                                .accentBorder
                                                          : WorkspaceTheme
                                                                .borderSubtle,
                                                    ),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    formattedNum,
                                                    style: TextStyle(
                                                      fontFamily:
                                                          AuthTheme.fontFamily,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: isSelected
                                                          ? WorkspaceTheme
                                                                .accentCobalt
                                                          : WorkspaceTheme
                                                                .textSecondary,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),

                                                // Title and Pages
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        chapter['name'] ??
                                                            chapter['title'] ??
                                                            'Chapter',
                                                        style: TextStyle(
                                                          fontFamily: AuthTheme
                                                              .fontFamily,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          fontSize: 14,
                                                          color: isSelected
                                                              ? WorkspaceTheme
                                                                    .textPrimary
                                                              : WorkspaceTheme
                                                                    .textPrimary
                                                                    .withValues(
                                                                      alpha:
                                                                          0.75,
                                                                    ),
                                                          letterSpacing: -0.2,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      if (chapter['start_page'] !=
                                                              null &&
                                                          chapter['end_page'] !=
                                                              null) ...[
                                                        const SizedBox(
                                                          height: 3,
                                                        ),
                                                        Text(
                                                          'Pages ${chapter["start_page"]}–${chapter["end_page"]}',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                AuthTheme
                                                                    .fontFamily,
                                                            fontSize: 11,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: WorkspaceTheme
                                                                .textSecondary,
                                                          ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                ),

                                                // Weightage Stepper if enabled & selected
                                                if (_state
                                                        .enableChapterWeightage &&
                                                    isSelected) ...[
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    behavior:
                                                        HitTestBehavior.opaque,
                                                    onTap:
                                                        () {}, // Absorb tap from card
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 4,
                                                            vertical: 2,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: WorkspaceTheme
                                                            .accentLight,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              10,
                                                            ),
                                                        border: Border.all(
                                                          color: WorkspaceTheme
                                                              .accentBorder,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            onTap: weightage > 0
                                                                ? () {
                                                                    setState(() {
                                                                      _state.updateChapterWeightage(
                                                                        chapterId,
                                                                        weightage -
                                                                                    5 <
                                                                                0
                                                                            ? 0
                                                                            : weightage -
                                                                                  5,
                                                                      );
                                                                    });
                                                                  }
                                                                : null,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    2.0,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .remove_rounded,
                                                                size: 15,
                                                                color:
                                                                    weightage >
                                                                        0
                                                                    ? WorkspaceTheme
                                                                          .accentCobalt
                                                                    : WorkspaceTheme
                                                                          .textMuted,
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            onTap: () =>
                                                                _openWeightageSheet(
                                                                  focusChapterId:
                                                                      chapterId,
                                                                ),
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        3,
                                                                  ),
                                                              child: Text(
                                                                '$weightage%',
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      AuthTheme
                                                                          .fontFamily,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: WorkspaceTheme
                                                                      .accentCobalt,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            behavior:
                                                                HitTestBehavior
                                                                    .opaque,
                                                            onTap:
                                                                weightage < 100
                                                                ? () {
                                                                    setState(() {
                                                                      _state.updateChapterWeightage(
                                                                        chapterId,
                                                                        weightage +
                                                                                    5 >
                                                                                100
                                                                            ? 100
                                                                            : weightage +
                                                                                  5,
                                                                      );
                                                                    });
                                                                  }
                                                                : null,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    2.0,
                                                                  ),
                                                              child: Icon(
                                                                Icons
                                                                    .add_rounded,
                                                                size: 15,
                                                                color:
                                                                    weightage <
                                                                        100
                                                                    ? WorkspaceTheme
                                                                          .accentCobalt
                                                                    : WorkspaceTheme
                                                                          .textMuted,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],

                                                const SizedBox(width: 10),

                                                // Selection Checkbox
                                                Container(
                                                  width: 22,
                                                  height: 22,
                                                  decoration: BoxDecoration(
                                                    color: isSelected
                                                        ? WorkspaceTheme
                                                              .accentCobalt
                                                        : Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                    border: Border.all(
                                                      color: isSelected
                                                          ? WorkspaceTheme
                                                                .accentCobalt
                                                          : WorkspaceTheme
                                                                .borderMedium,
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: isSelected
                                                      ? const Icon(
                                                          Icons.check_rounded,
                                                          color: Colors.white,
                                                          size: 15,
                                                        )
                                                      : null,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                              ],
                            ],
                          ),
                        ),
                ),

                // Bottom Continue Action Bar
                WizardBottomBar(
                  text: 'Continue',
                  onPressed: _canContinue
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaperWizardStepMarks(
                                subject: widget.subject,
                                state: _state,
                              ),
                            ),
                          );
                        }
                      : null,
                  helperWidget:
                      _state.enableChapterWeightage &&
                          _state.totalChapterWeightage != 100
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFECACA)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 16,
                                color: AuthTheme.error,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Total weightage must equal 100% to continue',
                                  style: TextStyle(
                                    fontFamily: AuthTheme.fontFamily,
                                    color: AuthTheme.error,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
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
