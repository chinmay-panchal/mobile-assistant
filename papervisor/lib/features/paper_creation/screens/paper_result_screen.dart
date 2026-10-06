import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../workspace/widgets/workspace_primary_button.dart';
import '../../../core/utils/responsive.dart';
import '../../auth/theme/auth_theme.dart';
import 'pdf_preview_screen.dart';
import '../models/paper_wizard_state.dart';
import 'generating_loader_screen.dart';

class PaperResultScreen extends StatelessWidget {
  final Map<String, dynamic> subject;
  final Map<String, dynamic> paper;
  final PaperWizardState? wizardState;
  final String? originalTitle;

  const PaperResultScreen({
    super.key,
    required this.subject,
    required this.paper,
    this.wizardState,
    this.originalTitle,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);
    final showWebBack = kIsWeb && !Responsive.isMobile(context);
    final String title = paper['title'] ?? 'Generated Paper';
    final int marks = paper['total_marks'] ?? 0;
    final String difficulty = paper['difficulty'] ?? 'Balanced';
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

        if (choiceGroup == null || choiceGroup != currentChoiceGroup) {
          sectionUniqueQuestions++;
          sectionMarks += (q['marks'] as num?)?.toInt() ?? 0;
          currentChoiceGroup = choiceGroup;
        }
      }

      uniqueQuestionsCount += sectionUniqueQuestions;

      return _sectionRow(
        sectionName.isNotEmpty ? sectionName.substring(0, 1) : 'S',
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
        backgroundColor: WorkspaceTheme.canvas,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      children: [
                        // Optional Back Navigation Button (Shown on Web Desktop/Tablet only, hidden on phones)
                        if (showWebBack) ...[
                          Tooltip(
                            message: 'Back',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.popUntil(
                                      context,
                                      (route) => route.isFirst,
                                    );
                                  }
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: WorkspaceTheme.surfaceMuted,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: WorkspaceTheme.borderSubtle,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 18,
                                    color: WorkspaceTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],

                        // Subject Icon Badge
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: WorkspaceTheme.isDark
                                ? const Color(0xFF1E293B)
                                : const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: WorkspaceTheme.isDark
                                  ? const Color(0xFF334155)
                                  : const Color(0xFFBAE6FD),
                            ),
                          ),
                          child: Icon(
                            Icons.auto_stories_rounded,
                            color: WorkspaceTheme.accentCobalt,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject['name'] ?? 'Subject',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: WorkspaceTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                'Paper Ready! 🎉',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: WorkspaceTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(
                              AuthTheme.radiusPill,
                            ),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AuthTheme.success,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Generated',
                                style: TextStyle(
                                  fontFamily: AuthTheme.fontFamily,
                                  color: AuthTheme.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          // Paper Summary Card
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: WorkspaceTheme.surfaceWhite,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: WorkspaceTheme.borderSubtle,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Top subtle accent bar
                                Container(
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: WorkspaceTheme.accentCobalt,
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        (subject['name'] ?? 'SUBJECT')
                                            .toString()
                                            .toUpperCase(),
                                        style: TextStyle(
                                          fontFamily: AuthTheme.fontFamily,
                                          color: WorkspaceTheme.textSecondary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontFamily: AuthTheme.fontFamily,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 18,
                                          color: WorkspaceTheme.textPrimary,
                                          letterSpacing: -0.3,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Exam Paper · ${subject['name'] ?? ''}',
                                        style: TextStyle(
                                          fontFamily: AuthTheme.fontFamily,
                                          color: WorkspaceTheme.textSecondary,
                                          fontSize: 13,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 20),

                                      // Metrics Row
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                          horizontal: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: WorkspaceTheme.surfaceMuted,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                          border: Border.all(
                                            color: WorkspaceTheme.borderSubtle,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            _metaStat(
                                              'QUESTIONS',
                                              '$uniqueQuestionsCount',
                                            ),
                                            _vertDivider(),
                                            _metaStat('MAX. MARKS', '$marks'),
                                            _vertDivider(),
                                            _metaStat(
                                              'DIFFICULTY',
                                              difficulty[0].toUpperCase() +
                                                  difficulty
                                                      .substring(1)
                                                      .toLowerCase(),
                                            ),
                                          ],
                                        ),
                                      ),

                                      const SizedBox(height: 20),
                                      Divider(
                                        color: WorkspaceTheme.borderSubtle,
                                        height: 1,
                                      ),
                                      const SizedBox(height: 10),

                                      if (sectionWidgets.isEmpty)
                                        Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Text(
                                            'No sections available.',
                                            style: TextStyle(
                                              fontFamily: AuthTheme.fontFamily,
                                              color:
                                                  WorkspaceTheme.textSecondary,
                                            ),
                                          ),
                                        )
                                      else
                                        ...sectionWidgets,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Action buttons - Unified consistent design
                          WorkspacePrimaryButton(
                            text: 'Preview PDF',
                            icon: const Icon(
                              Icons.visibility_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            height: 48,
                            onPressed: () {
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
                          ),
                          const SizedBox(height: 10),
                          if (wizardState != null)
                            Row(
                              children: [
                                Expanded(
                                  child: WorkspacePrimaryButton(
                                    text: 'Remake',
                                    icon: Icon(
                                      Icons.refresh_rounded,
                                      size: 18,
                                      color: WorkspaceTheme.textPrimary,
                                    ),
                                    isSecondary: true,
                                    height: 46,
                                    onPressed: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              GeneratingLoaderScreen(
                                                subject: subject,
                                                state: wizardState!,
                                                title:
                                                    originalTitle ??
                                                    paper['title'] ??
                                                    'Generated Paper',
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: WorkspacePrimaryButton(
                                    text: 'Home',
                                    icon: Icon(
                                      Icons.home_outlined,
                                      size: 18,
                                      color: WorkspaceTheme.textPrimary,
                                    ),
                                    isSecondary: true,
                                    height: 46,
                                    onPressed: () {
                                      Navigator.popUntil(
                                        context,
                                        (route) => route.isFirst,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          else
                            WorkspacePrimaryButton(
                              text: 'Return to Home',
                              icon: Icon(
                                Icons.home_outlined,
                                size: 18,
                                color: WorkspaceTheme.textPrimary,
                              ),
                              isSecondary: true,
                              height: 46,
                              onPressed: () {
                                Navigator.popUntil(
                                  context,
                                  (route) => route.isFirst,
                                );
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
          ),
        ),
      ),
    );
  }

  Color _getColorForSection(String sectionName) {
    if (sectionName.toLowerCase().contains('a')) return AuthTheme.primary;
    if (sectionName.toLowerCase().contains('b')) return const Color(0xFF2563EB);
    if (sectionName.toLowerCase().contains('c')) return const Color(0xFF0D9488);
    return const Color(0xFFD97706);
  }

  Widget _metaStat(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            color: WorkspaceTheme.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontFamily: AuthTheme.fontFamily,
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: WorkspaceTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _vertDivider() {
    return Container(width: 1, height: 28, color: WorkspaceTheme.borderSubtle);
  }

  Widget _sectionRow(
    String letter,
    Color color,
    String title,
    int marks,
    int qCount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              letter,
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: WorkspaceTheme.textPrimary,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: WorkspaceTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '$qCount Qs · $marks Marks',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: WorkspaceTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
