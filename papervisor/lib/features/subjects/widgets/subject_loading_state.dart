import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';
import '../../workspace/constants/workspace_theme.dart';

/// Clean skeleton placeholder grid shown during subject data fetching.
/// Uses the exact same crossAxisCount and childAspectRatio as the real grid.
class SubjectLoadingState extends StatefulWidget {
  const SubjectLoadingState({super.key});

  @override
  State<SubjectLoadingState> createState() => _SubjectLoadingStateState();
}

class _SubjectLoadingStateState extends State<SubjectLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.45, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Mirror exactly what subject_grid_screen.dart computes
    final crossAxisCount = Responsive.value<int>(
      context: context,
      mobile: 2,
      tablet: 3,
      desktop: 4,
    );
    final childAspectRatio = Responsive.value<double>(
      context: context,
      mobile: 1.05,
      tablet: 1.12,
      desktop: 1.15,
    );

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseAnim.value,
          child: GridView.builder(
            itemCount: crossAxisCount * 2, // 2 rows of ghost cards
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: childAspectRatio,
            ),
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        border: Border.all(color: WorkspaceTheme.borderSubtle, width: 1.2),
        boxShadow: WorkspaceTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top Row: icon badge + menu dot placeholder
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),

          // Bottom: name + book count placeholders
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 14,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 10,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
