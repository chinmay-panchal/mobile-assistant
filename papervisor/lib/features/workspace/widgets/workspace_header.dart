import 'package:flutter/material.dart';
import '../constants/workspace_theme.dart';

/// Top header for the Home/Workspaces screen featuring user greeting,
/// title, and quick action icon buttons for PYQ search and logout.
class WorkspaceHeader extends StatelessWidget {
  final VoidCallback onSearchPyq;
  final VoidCallback onLogout;

  const WorkspaceHeader({
    super.key,
    required this.onSearchPyq,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Greeting and Title
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtle, mature Educator status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: WorkspaceTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
                  border: Border.all(color: WorkspaceTheme.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: WorkspaceTheme.primaryDark.withValues(alpha: 0.03),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 13,
                      color: WorkspaceTheme.accentCobalt,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Hello Educator',
                      style: TextStyle(
                        fontFamily: WorkspaceTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: WorkspaceTheme.textSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your Workspaces',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: WorkspaceTheme.textPrimary,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Manage subjects, papers and study material.',
                style: TextStyle(
                  fontFamily: WorkspaceTheme.fontFamily,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w400,
                  color: WorkspaceTheme.textSecondary,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Action Buttons: Search & Logout
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildActionButton(
              icon: Icons.search_rounded,
              tooltip: 'Search PYQs',
              iconColor: WorkspaceTheme.textPrimary,
              onTap: onSearchPyq,
            ),
            const SizedBox(width: 8),
            _buildActionButton(
              icon: Icons.logout_rounded,
              tooltip: 'Sign Out',
              iconColor: WorkspaceTheme.textTertiary,
              hoverColor: WorkspaceTheme.error,
              onTap: onLogout,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required Color iconColor,
    Color? hoverColor,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
          onTap: onTap,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: WorkspaceTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(WorkspaceTheme.radiusElement),
              border: Border.all(color: WorkspaceTheme.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: WorkspaceTheme.primaryDark.withValues(alpha: 0.03),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 19),
          ),
        ),
      ),
    );
  }
}
