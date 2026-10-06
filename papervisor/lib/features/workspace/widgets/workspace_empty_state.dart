import 'package:flutter/material.dart';
import '../../auth/widgets/auth_illustration.dart';
import '../constants/workspace_assets.dart';
import '../constants/workspace_theme.dart';
import 'workspace_primary_button.dart';

/// Friendly, welcoming empty state displayed when no workspaces exist yet.
/// Features a permanent gentle floating (up-down) animation, hover scale expansion,
/// and clickable interaction to create a new workspace.
class WorkspaceEmptyState extends StatefulWidget {
  final VoidCallback? onCreateWorkspace;
  final bool showButton;

  const WorkspaceEmptyState({
    super.key,
    this.onCreateWorkspace,
    this.showButton = false,
  });

  @override
  State<WorkspaceEmptyState> createState() => _WorkspaceEmptyStateState();
}

class _WorkspaceEmptyStateState extends State<WorkspaceEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canClick = widget.onCreateWorkspace != null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Floating & Hoverable Illustration (tightly bounded hit area)
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -7.0 * _floatAnimation.value),
                  child: child,
                );
              },
              child: MouseRegion(
                cursor: canClick ? SystemMouseCursors.click : MouseCursor.defer,
                onEnter: (_) {
                  if (canClick) setState(() => _isHovered = true);
                },
                onExit: (_) {
                  if (canClick) setState(() => _isHovered = false);
                },
                child: GestureDetector(
                  onTap: widget.onCreateWorkspace,
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 220,
                    height: 155,
                    child: Center(
                      child: AnimatedScale(
                        scale: _isHovered ? 1.08 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        child: const AuthIllustration(
                          assetPath: WorkspaceAssets.emptyWorkspaces,
                          height: 155,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Clickable Title
            MouseRegion(
              cursor: canClick ? SystemMouseCursors.click : MouseCursor.defer,
              child: GestureDetector(
                onTap: widget.onCreateWorkspace,
                child: Text(
                  'Create your first workspace',
                  style: TextStyle(
                    fontFamily: WorkspaceTheme.fontFamily,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: WorkspaceTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Subtitle
            Text(
              'Organize your classes, subjects and exam papers together in one calm space.',
              style: TextStyle(
                fontFamily: WorkspaceTheme.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w400,
                color: WorkspaceTheme.textSecondary,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            if (widget.showButton && canClick) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 240,
                child: WorkspacePrimaryButton(
                  text: 'Create Workspace',
                  onPressed: widget.onCreateWorkspace,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
