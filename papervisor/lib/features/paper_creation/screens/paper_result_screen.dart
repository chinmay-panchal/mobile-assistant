import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'pdf_preview_screen.dart';
import '../models/paper_wizard_state.dart';
import 'generating_loader_screen.dart';

class PaperResultScreen extends StatelessWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> paper;
  final PaperWizardState? wizardState;
  final String? originalTitle;

  const PaperResultScreen({
    Key? key,
    required this.subject,
    required this.paper,
    this.wizardState,
    this.originalTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String title = paper['title'] ?? 'Generated Paper';
    final int marks = paper['total_marks'] ?? 0;
    final String difficulty = paper['difficulty'] ?? 'Unknown';
    final List<dynamic> questions = paper['questions'] ?? [];
    
    // Group questions by section
    final Map<String, List<dynamic>> sections = {};
    for (final q in questions) {
      final sectionName = q['section_name'] ?? 'General';
      sections.putIfAbsent(sectionName, () => []).add(q);
    }
    
    int uniqueQuestionsCount = 0;
    
    // Section widgets
    final sectionWidgets = sections.entries.map((entry) {
      final sectionName = entry.key;
      final sectionQuestions = entry.value;
      int sectionMarks = 0;
      int sectionUniqueQuestions = 0;
      String? currentChoiceGroup;

      for (final q in sectionQuestions) {
        final String? choiceGroup = q['choice_group'];
        
        // Only count the question and its marks if it's a new standalone question 
        // or the FIRST alternative of a choice group
        if (choiceGroup == null || choiceGroup != currentChoiceGroup) {
          sectionUniqueQuestions++;
          sectionMarks += (q['marks'] as num?)?.toInt() ?? 0;
          currentChoiceGroup = choiceGroup;
        }
      }
      
      uniqueQuestionsCount += sectionUniqueQuestions;

      return _sectionRow(
        sectionName.substring(0, 1),
        _getColorForSection(sectionName),
        sectionName,
        sectionMarks,
        sectionUniqueQuestions,
      );
    }).toList();

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.popUntil(context, (route) => route.isFirst);
          }
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top header row with Back button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${subject['name'] ?? 'Subject'}',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Paper Ready! 🎉',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check, color: AppColors.success, size: 14),
                        const SizedBox(width: 4),
                        const Text(
                          'Generated',
                          style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Paper Preview Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.divider.withOpacity(0.6),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Gradient accent bar at top
                          Container(
                            height: 6,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.primaryDark, AppColors.primaryLight, Color(0xFF06B6D4)],
                              ),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  (subject['name'] ?? 'SUBJECT').toString().toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.textTertiary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Subject: ${subject['name'] ?? 'N/A'}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _metaStat('QUESTIONS', '$uniqueQuestionsCount'),
                                    _vertDivider(),
                                    _metaStat('MAX. MARKS', '$marks'),
                                    _vertDivider(),
                                    _metaStat('DIFFICULTY', difficulty[0].toUpperCase() + difficulty.substring(1).toLowerCase()),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Divider(color: AppColors.divider),
                                const SizedBox(height: 8),
                                if (sectionWidgets.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Text('No sections available.', style: TextStyle(color: AppColors.textSecondary)),
                                  )
                                else
                                  ...sectionWidgets,
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats row
                    Row(
                      children: [
                        _statPill('$uniqueQuestionsCount', 'Questions', AppColors.primary),
                        const SizedBox(width: 12),
                        _statPill('${(paper['selected_chapter_ids'] as List?)?.length ?? 0}', 'Chapters', AppColors.success),
                        const SizedBox(width: 12),
                        _statPill('$marks', 'Total Marks', const Color(0xFF9333EA)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfPreviewScreen(
                                    subject: subject,
                                    paper: paper,
                                  ),
                                ),
                              );
                            },
                            child: _gradientButton('Preview', Icons.preview, [AppColors.primaryDark, AppColors.primaryLight]),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (wizardState != null) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GeneratingLoaderScreen(
                                      subject: subject,
                                      state: wizardState!,
                                      title: originalTitle ?? paper['title'] ?? 'Generated Paper',
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.popUntil(context, (route) => route.isFirst);
                              }
                            },
                            child: _gradientButton('Retry', Icons.refresh, [AppColors.warning, const Color(0xFFF59E0B)]),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: const BorderSide(color: AppColors.primary, width: 1.5),
                          backgroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.popUntil(context, (route) => route.isFirst);
                        },
                        icon: const Icon(Icons.home_outlined, color: AppColors.primary),
                        label: const Text(
                          'Done / Back to Home',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),


                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Color _getColorForSection(String sectionName) {
    if (sectionName.toLowerCase().contains('a')) return const Color(0xFF6366F1);
    if (sectionName.toLowerCase().contains('b')) return AppColors.success;
    if (sectionName.toLowerCase().contains('c')) return AppColors.warning;
    return AppColors.error;
  }

  Widget _metaStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ],
    );
  }

  Widget _vertDivider() {
    return Container(width: 1, height: 32, color: AppColors.divider);
  }

  Widget _sectionRow(String letter, Color color, String title, int marks, int qCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color.withOpacity(0.12),
                child: Text(letter, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Text('[$marks marks]', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 6,
                  width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Text('$qCount questions', style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.divider.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _gradientButton(String label, IconData icon, List<Color> colors) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors.first.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: null, // Just UI for now, except for the wrapping GestureDetector for Done
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
