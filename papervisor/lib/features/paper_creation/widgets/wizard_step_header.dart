import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/theme_provider.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Clean, seamless header for all 5 steps of the Paper Creation Wizard.
/// Designed to visually match [SubjectDetailHeader] with subject identity,
/// step progress pill, title, subtitle, and 5-segment progress bar.
class WizardStepHeader extends StatelessWidget {
  final String subjectName;
  final int currentStep; // 1-indexed (1 to 5)
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onBack;

  const WizardStepHeader({
    super.key,
    required this.subjectName,
    required this.currentStep,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    Provider.of<ThemeProvider?>(context, listen: true);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      color: Colors.transparent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Identity Row: Back Button (Web only) + Subject Icon Badge + Subject Title & Step Pill
          Row(
            children: [
              // Optional Back Navigation Button (Shown on Web only, hidden on mobile)
              if (kIsWeb && onBack != null) ...[
                Tooltip(
                  message: 'Back',
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onBack,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: WorkspaceTheme.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: WorkspaceTheme.borderSubtle,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 20,
                          color: WorkspaceTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Subject Icon Container (Same styling as SubjectDetailHeader)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.isDark
                      ? const Color(0xFF151F32)
                      : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: WorkspaceTheme.isDark
                        ? const Color(0xFF1E40AF)
                        : const Color(0xFFBAE6FD),
                  ),
                ),
                child: const Icon(
                  Icons.auto_stories_rounded,
                  size: 22,
                  color: Color(0xFF0284C7),
                ),
              ),

              const SizedBox(width: 12),

              // Subject Name & Step Counter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      subjectName.toUpperCase(),
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: WorkspaceTheme.textPrimary,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: WorkspaceTheme.isDark
                                ? const Color(0xFF151F32)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(
                              WorkspaceTheme.radiusPill,
                            ),
                            border: Border.all(
                              color: WorkspaceTheme.isDark
                                  ? const Color(0xFF1E40AF)
                                  : const Color(0xFFBAE6FD),
                            ),
                          ),
                          child: Text(
                            'Step $currentStep of 5',
                            style: const TextStyle(
                              fontFamily: WorkspaceTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0284C7),
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (trailing != null) ...[trailing!, const SizedBox(width: 8)],

              // Home Button at top right
              Tooltip(
                message: 'Home',
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: WorkspaceTheme.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: WorkspaceTheme.borderSubtle),
                      ),
                      child: Icon(
                        Icons.home_outlined,
                        size: 20,
                        color: WorkspaceTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Step Title & Subtitle
          Text(
            title,
            style: TextStyle(
              fontFamily: WorkspaceTheme.fontFamily,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: WorkspaceTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: WorkspaceTheme.fontFamily,
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
              color: WorkspaceTheme.textSecondary,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          // 5-Segment Progress Bar
          Row(
            children: List.generate(5, (index) {
              final isCompleted = index < currentStep;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index == 4 ? 0 : 6),
                  height: 5,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? WorkspaceTheme.primaryDark
                        : WorkspaceTheme.borderSubtle,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
