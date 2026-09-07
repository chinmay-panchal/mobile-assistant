import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/paper_service.dart';
import '../models/paper_wizard_state.dart';
import 'paper_result_screen.dart';

class GeneratingLoaderScreen extends StatefulWidget {
  final Map<String, dynamic> subject;
  final PaperWizardState state;
  final String title;

  const GeneratingLoaderScreen({
    Key? key,
    required this.subject,
    required this.state,
    required this.title,
  }) : super(key: key);

  @override
  State<GeneratingLoaderScreen> createState() => _GeneratingLoaderScreenState();
}

class _GeneratingLoaderScreenState extends State<GeneratingLoaderScreen>
    with TickerProviderStateMixin {
  final PaperService _paperService = PaperService();

  final List<String> _messages = [
    'Analysing your chapters...',
    'Selecting question types...',
    'Applying difficulty settings...',
    'Balancing marks across topics...',
    'Finalising your exam paper...',
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
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      setState(() {
        _dotCount = (_dotCount % 3) + 1;
      });
    });

    _messageTimer = Timer.periodic(const Duration(seconds: 2), (t) {
      if (_messageIndex < _messages.length - 1) {
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
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
        );
        Navigator.pop(context); // Go back to the previous screen on error
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
    final theme = Theme.of(context);
    final dots = '.' * _dotCount;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryLight, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Generating Paper$dots',
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  _messages[_messageIndex],
                  key: ValueKey(_messageIndex),
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 48),
              // Step progress dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_messages.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _messageIndex ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i <= _messageIndex ? AppColors.primary : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const Spacer(),
              Text(
                'Please don\'t close the app.',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                'This usually takes 10–30 seconds',
                style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
