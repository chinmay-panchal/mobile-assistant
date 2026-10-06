import 'package:flutter/material.dart';
import '../../workspace/constants/workspace_theme.dart';
import '../../auth/theme/auth_theme.dart';

/// Representation of an active section in the format configuration.
class FormatSectionSummary {
  final String name; // e.g. "Section A"
  final String typeName; // e.g. "MCQ", "Short Answer"
  final String questionType; // e.g. "MCQ", "SHORT_ANSWER"
  final int count;
  final int marksEach;

  const FormatSectionSummary({
    required this.name,
    required this.typeName,
    required this.questionType,
    required this.count,
    required this.marksEach,
  });
}

/// Rich interactive component for selecting and configuring paper alternatives / internal choice:
/// 1. Simple OR (every question has an alternative)
/// 2. Attempt X out of Y questions
/// 3. Either this section or that section (whole section alternative)
class AlternativeTypeSelector extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onToggleEnabled;
  final int selectedType; // 1, 2, or 3
  final ValueChanged<int> onTypeChanged;
  final List<FormatSectionSummary> sections;
  final List<String> selectedSections;
  final ValueChanged<List<String>> onSectionsChanged;
  final Map<String, int> attemptCounts;
  final ValueChanged<Map<String, int>> onAttemptCountsChanged;

  const AlternativeTypeSelector({
    super.key,
    required this.isEnabled,
    required this.onToggleEnabled,
    required this.selectedType,
    required this.onTypeChanged,
    required this.sections,
    required this.selectedSections,
    required this.onSectionsChanged,
    required this.attemptCounts,
    required this.onAttemptCountsChanged,
  });

  List<FormatSectionSummary> get _currentSections {
    if (sections.isEmpty) return [];
    return sections.where((s) => selectedSections.contains(s.name)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WorkspaceTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Toggle Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Internal Choice / Alternatives',
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
                      'Configure question alternatives, elective attempts, or section choices',
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 12,
                        color: WorkspaceTheme.textSecondary,
                        height: 1.3,
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
                value: isEnabled,
                onChanged: onToggleEnabled,
              ),
            ],
          ),

          // Expanded Configuration Area when Toggle is ON
          if (isEnabled) ...[
            const SizedBox(height: 16),
            Divider(height: 1, color: WorkspaceTheme.borderSubtle),
            const SizedBox(height: 16),

            Text(
              'SELECT PAPER ALTERNATIVE TEMPLATE',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontWeight: FontWeight.w800,
                fontSize: 11,
                letterSpacing: 0.8,
                color: WorkspaceTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            // 3 Visual Paper Preview Alternative Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 600;
                if (isNarrow) {
                  return Column(
                    children: [
                      _buildAlternativeCard(
                        type: 1,
                        imageAsset:
                            'assets/paper_creation/alternatives/simple_question_or.jpg',
                        title: 'Simple OR Template',
                        subtitle:
                            'Every question includes an internal "OR" alternative',
                        badgeText: 'Per-Question',
                        badgeIcon: Icons.swap_horiz_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildAlternativeCard(
                        type: 2,
                        imageAsset:
                            'assets/paper_creation/alternatives/attempt_x_of_y.jpg',
                        title: 'Attempt X of Y Template',
                        subtitle:
                            'Section instruction: attempt any X out of Y questions',
                        badgeText: 'Elective Choice',
                        badgeIcon: Icons.checklist_rounded,
                      ),
                      const SizedBox(height: 12),
                      _buildAlternativeCard(
                        type: 3,
                        imageAsset:
                            'assets/paper_creation/alternatives/section_or.jpg',
                        title: 'Either / Or Section Template',
                        subtitle:
                            'Full alternative counterpart for the entire section',
                        badgeText: 'Whole Section',
                        badgeIcon: Icons.alt_route_rounded,
                      ),
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildAlternativeCard(
                        type: 1,
                        imageAsset:
                            'assets/paper_creation/alternatives/simple_question_or.jpg',
                        title: 'Simple OR Template',
                        subtitle: 'Every question has an internal "OR"',
                        badgeText: 'Per-Question',
                        badgeIcon: Icons.swap_horiz_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAlternativeCard(
                        type: 2,
                        imageAsset:
                            'assets/paper_creation/alternatives/attempt_x_of_y.jpg',
                        title: 'Attempt X of Y Template',
                        subtitle: 'Attempt any X out of Y questions',
                        badgeText: 'Elective Choice',
                        badgeIcon: Icons.checklist_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAlternativeCard(
                        type: 3,
                        imageAsset:
                            'assets/paper_creation/alternatives/section_or.jpg',
                        title: 'Either / Or Section Template',
                        subtitle: 'Full alternative section counterpart',
                        badgeText: 'Whole Section',
                        badgeIcon: Icons.alt_route_rounded,
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // Secondary Follow-Up Questions Form
            _buildFollowUpQuestions(context),
          ],
        ],
      ),
    );
  }

  Widget _buildAlternativeCard({
    required int type,
    required String imageAsset,
    required String title,
    required String subtitle,
    required String badgeText,
    required IconData badgeIcon,
  }) {
    final isSelected = selectedType == type;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onTypeChanged(type),
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? (WorkspaceTheme.isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF0F7FF))
                : (WorkspaceTheme.isDark
                      ? const Color(0xFF0F172A)
                      : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? WorkspaceTheme.accentCobalt
                  : WorkspaceTheme.borderSubtle,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: WorkspaceTheme.accentCobalt.withValues(
                        alpha: 0.15,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail with badge
              Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: WorkspaceTheme.surfaceMuted,
                        child: Center(
                          child: Icon(
                            badgeIcon,
                            size: 32,
                            color: WorkspaceTheme.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Pill Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(badgeIcon, size: 11, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            badgeText,
                            style: const TextStyle(
                              fontFamily: AuthTheme.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Selected Indicator
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: WorkspaceTheme.accentCobalt,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),

              // Title & Description
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? (WorkspaceTheme.isDark
                                  ? Colors.white
                                  : const Color(0xFF0F172A))
                            : WorkspaceTheme.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: AuthTheme.fontFamily,
                        fontSize: 11.5,
                        color: WorkspaceTheme.textSecondary,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowUpQuestions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceMuted,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WorkspaceTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedType == 1) ...[
            _buildHeaderTag(
              icon: Icons.swap_horiz_rounded,
              title: 'SIMPLE OR CONFIGURATION',
            ),
            const SizedBox(height: 8),
            Text(
              'Which section should have an internal alternative for every question?',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: WorkspaceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildSectionChips(),
            const SizedBox(height: 10),
            _buildInfoNote(
              'Every question in ${selectedSections.isNotEmpty ? selectedSections.join(", ") : "the selected section"} will automatically include an internal "OR" alternative.',
            ),
          ] else if (selectedType == 2) ...[
            _buildHeaderTag(
              icon: Icons.checklist_rounded,
              title: 'ATTEMPT X OF Y CONFIGURATION',
            ),
            const SizedBox(height: 8),
            Text(
              'Select the section where students have elective choice:',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: WorkspaceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildSectionChips(),
            const SizedBox(height: 14),

            // Number of questions to attempt
            Text(
              'How many questions should students attempt?',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: WorkspaceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildAttemptCounter(),
            const SizedBox(height: 10),
            _buildInfoNote(
              'Students will be asked to answer the required number of questions out of the available questions in the selected section.',
            ),
          ] else if (selectedType == 3) ...[
            _buildHeaderTag(
              icon: Icons.alt_route_rounded,
              title: 'EITHER / OR SECTION CONFIGURATION',
            ),
            const SizedBox(height: 8),
            Text(
              'Which whole section should have a full alternative counterpart?',
              style: TextStyle(
                fontFamily: AuthTheme.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: WorkspaceTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildSectionChips(),
            const SizedBox(height: 10),
            _buildInfoNote(
              'An equivalent parallel alternative will be generated for ${selectedSections.isNotEmpty ? selectedSections.join(", ") : "the selected section"}. In the exam, students will choose between attempting the standard section or the alternative section.',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderTag({required IconData icon, required String title}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: WorkspaceTheme.accentCobalt),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontWeight: FontWeight.w800,
              fontSize: 11,
              letterSpacing: 0.6,
              color: WorkspaceTheme.accentCobalt,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionChips() {
    if (sections.isEmpty) {
      return Text(
        'No sections available in current format',
        style: TextStyle(
          fontFamily: AuthTheme.fontFamily,
          fontSize: 12,
          color: WorkspaceTheme.textSecondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections.map((sec) {
        final isChosen = selectedSections.contains(sec.name);
        final isDisabled = false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      final newSelections = List<String>.from(selectedSections);
                      if (isChosen) {
                        newSelections.remove(sec.name);
                      } else {
                        newSelections.add(sec.name);
                      }
                      onSectionsChanged(newSelections);

                      if (!isChosen && selectedType == 2) {
                        final newCounts = Map<String, int>.from(attemptCounts);
                        newCounts[sec.name] = sec.count + 1;
                        onAttemptCountsChanged(newCounts);
                      }
                    },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDisabled
                      ? (WorkspaceTheme.isDark
                            ? const Color(0xFF1E293B).withValues(alpha: 0.3)
                            : Colors.grey.shade200)
                      : isChosen
                      ? WorkspaceTheme.accentCobalt
                      : (WorkspaceTheme.isDark
                            ? const Color(0xFF1E293B)
                            : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDisabled
                        ? WorkspaceTheme.borderSubtle.withValues(alpha: 0.3)
                        : isChosen
                        ? WorkspaceTheme.accentCobalt
                        : WorkspaceTheme.borderSubtle,
                    width: isChosen ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isChosen
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 20,
                      color: isDisabled
                          ? WorkspaceTheme.textSecondary.withValues(alpha: 0.5)
                          : isChosen
                          ? Colors.white
                          : WorkspaceTheme.textSecondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        sec.name,
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 13.5,
                          fontWeight: isChosen && !isDisabled
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isDisabled
                              ? WorkspaceTheme.textSecondary.withValues(
                                  alpha: 0.5,
                                )
                              : isChosen
                              ? Colors.white
                              : WorkspaceTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isChosen
                            ? Colors.white.withValues(alpha: 0.25)
                            : WorkspaceTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${sec.count} Qs • ${sec.typeName}',
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isChosen
                              ? Colors.white
                              : WorkspaceTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAttemptCounter() {
    if (selectedSections.isEmpty) {
      return Text(
        'Please select at least one section above.',
        style: TextStyle(
          fontFamily: AuthTheme.fontFamily,
          fontSize: 12,
          color: WorkspaceTheme.textSecondary,
        ),
      );
    }

    final sortedSections = List<String>.from(selectedSections)..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedSections.map((secName) {
        final curSec = sections.firstWhere(
          (s) => s.name == secName,
          orElse: () => sections.first,
        );
        final xCount = curSec.count;
        final yCount = attemptCounts[secName] ?? (xCount + 1);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                secName.toUpperCase(),
                style: TextStyle(
                  fontFamily: AuthTheme.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: WorkspaceTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  // Decrease button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: yCount > xCount + 1
                          ? () {
                              final newCounts = Map<String, int>.from(
                                attemptCounts,
                              );
                              newCounts[secName] = yCount - 1;
                              onAttemptCountsChanged(newCounts);
                            }
                          : null,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: WorkspaceTheme.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: WorkspaceTheme.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          Icons.remove_rounded,
                          size: 18,
                          color: yCount > xCount + 1
                              ? WorkspaceTheme.textPrimary
                              : WorkspaceTheme.borderSubtle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Display Box
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: WorkspaceTheme.cardBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: WorkspaceTheme.accentCobalt),
                      ),
                      child: Text(
                        'Attempt $xCount of $yCount Questions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AuthTheme.fontFamily,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: WorkspaceTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Increase button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        final newCounts = Map<String, int>.from(attemptCounts);
                        newCounts[secName] = yCount + 1;
                        onAttemptCountsChanged(newCounts);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: WorkspaceTheme.cardBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: WorkspaceTheme.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          size: 18,
                          color: WorkspaceTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoNote(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.info_outline_rounded,
          size: 14,
          color: WorkspaceTheme.accentCobalt,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AuthTheme.fontFamily,
              fontSize: 11.5,
              color: WorkspaceTheme.textSecondary,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
