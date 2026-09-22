import 'package:flutter/material.dart';
import '../constants/workspace_theme.dart';

/// Clean skeleton placeholder cards shown during workspace data fetching.
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
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, _) {
        return Opacity(
          opacity: _pulseAnim.value,
          child: ListView.builder(
            itemCount: 4,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) => _buildSkeletonCard(),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: WorkspaceTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(WorkspaceTheme.radiusCard),
        border: Border.all(color: WorkspaceTheme.borderSubtle, width: 1.2),
        boxShadow: WorkspaceTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: WorkspaceTheme.surfaceMuted,
              borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150,
                  height: 15,
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.surfaceMuted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 76,
                  height: 12,
                  decoration: BoxDecoration(
                    color: WorkspaceTheme.surfaceSubtle,
                    borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
                    border: Border.all(color: WorkspaceTheme.borderSubtle),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: WorkspaceTheme.surfaceSubtle,
              shape: BoxShape.circle,
              border: Border.all(color: WorkspaceTheme.borderSubtle),
            ),
          ),
        ],
      ),
    );
  }
}
