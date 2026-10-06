import 'package:flutter/material.dart';
import '../constants/workspace_theme.dart';

/// Clean skeleton placeholder grid matching the exact layout of the real
/// workspace/subject grid (same crossAxisCount logic, mainAxisExtent=168,
/// spacing=16) shown during data fetching.
class WorkspaceLoadingState extends StatefulWidget {
  const WorkspaceLoadingState({super.key});

  @override
  State<WorkspaceLoadingState> createState() => _WorkspaceLoadingStateState();
}

class _WorkspaceLoadingStateState extends State<WorkspaceLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.40, end: 0.90).animate(
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
    final width = MediaQuery.sizeOf(context).width;
    final int crossAxisCount = width < 640 ? 1 : (width < 960 ? 2 : 3);

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseAnim.value,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              mainAxisExtent: 168,
            ),
            itemCount: crossAxisCount * 2, // 2 rows of ghost cards
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        border: Border.all(color: WorkspaceTheme.borderSubtle, width: 1.2),
        boxShadow: WorkspaceTheme.cardShadow,
      ),
      padding: const EdgeInsets.all(14.0),
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
                width: 120,
                height: 14,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.surfaceMuted,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 72,
                height: 11,
                decoration: BoxDecoration(
                  color: WorkspaceTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(
                    WorkspaceTheme.radiusPill,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
