import 'dart:async';
import 'package:flutter/material.dart';
import '../../auth/theme/auth_theme.dart';
import '../../../../services/paper_service.dart';
import '../models/paper_wizard_state.dart';
import 'paper_result_screen.dart';

class GeneratingLoaderScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;
  final String title;

  const GeneratingLoaderScreen({
    super.key,
    required this.subject,
    required this.state,
    required this.title,
  });

  @override
  State<GeneratingLoaderScreen> createState() => _GeneratingLoaderScreenState();
}

class _GeneratingLoaderScreenState extends State<GeneratingLoaderScreen>
    with TickerProviderStateMixin {
  final PaperService _paperService = PaperService();

  final List<String> _messages = [
    'Analysing chosen textbook chapters...',
    'Selecting balanced question types...',
    'Applying difficulty distribution...',
    'Structuring sections and marks...',
    'Finalising your examination paper...',
  ];

  int _messageIndex = 0;
  int _dotCount = 1;
  Timer? _messageTimer;
  Timer? _dotTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.90, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dotTimer = Timer.periodic(const Duration(milliseconds: 450), (t) {
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount % 3) + 1;
        });
      }
    });

    _messageTimer = Timer.periodic(const Duration(seconds: 3), (t) {
      if (mounted && _messageIndex < _messages.length - 1) {
        setState(() => _messageIndex++);
      }
    });

    _generatePaper();
  }

  Future<void> _generatePaper() async {
    try {
      final generatedPaper = await _paperService.generatePaper(
        bookId: widget.state.bookId!,
        selectedChapterIds: widget.state.selectedChapterIds,
        generationMode: widget.state.generationMode,
        totalMarks: widget.state.totalMarks,
        difficulty: widget.state.difficulty,
        title: widget.title,
        includeAnswers: false,
        referencePaperId: widget.state.referencePaperId,
        questionConfigs: widget.state.isReferenceMode ? null : widget.state.questionConfigs,
        className: widget.state.className.isNotEmpty ? widget.state.className : null,
        timeAllowedMinutes: widget.state.timeAllowedMinutes,
        enableNumericalPercentage: widget.state.enableNumericalPercentage,
        numericalPercentage: widget.state.numericalPercentage,
        easyPercentage: widget.state.easyPercentage,
        mediumPercentage: widget.state.mediumPercentage,
        hardPercentage: widget.state.hardPercentage,
        enableChapterWeightage: widget.state.enableChapterWeightage,
        chapterWeightages: widget.state.chapterWeightages,
      );

      _stopTimers();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaperResultScreen(
              subject: widget.subject,
              paper: generatedPaper,
              wizardState: widget.state,
              originalTitle: widget.title,
            ),
          ),
        );
      }
    } catch (e) {
      _stopTimers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AuthTheme.error,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  void _stopTimers() {
    _messageTimer?.cancel();
    _dotTimer?.cancel();
  }

  @override
  void dispose() {
    _stopTimers();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              const Spacer(),

              // Pulsing AI Badge
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AuthTheme.primary, Color(0xFF6366F1), Color(0xFF818CF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AuthTheme.primary.withValues(alpha: 0.35),
                        blurRadius: 36,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: Colors.white,
                    size: 52,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Title
              Text(
                'Crafting Your Exam Paper$dots',
                style: const TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AuthTheme.textPrimary,
                  letterSpacing: -0.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Animated message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  style: const TextStyle(
                    fontFamily: AuthTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AuthTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 36),

              // Step Progress Pills
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_messages.length, (i) {
                  final isDoneOrCurrent = i <= _messageIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _messageIndex ? 26 : 8,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isDoneOrCurrent ? AuthTheme.primary : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),

              const Spacer(),

              // Reassuring Info Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: AuthTheme.primary),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Please keep this screen open',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AuthTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 1),
                          Text(
                            'Exam generation typically completes in 10–25 seconds.',
                            style: TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 11,
                              color: AuthTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
