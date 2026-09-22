import 'package:flutter/material.dart';
import '../../auth/widgets/auth_illustration.dart';
import '../constants/workspace_assets.dart';
import '../constants/workspace_theme.dart';
import 'workspace_primary_button.dart';

/// Friendly, welcoming empty state displayed when no workspaces exist yet.
class WorkspaceEmptyState extends StatelessWidget {
  final VoidCallback? onCreateWorkspace;

  const WorkspaceEmptyState({
    super.key,
    this.onCreateWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AuthIllustration(
              assetPath: WorkspaceAssets.emptyWorkspaces,
              height: 140,
            ),
            const SizedBox(height: 20),
            const Text(
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
            const SizedBox(height: 8),
            const Text(
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
            if (onCreateWorkspace != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: 240,
                child: WorkspacePrimaryButton(
                  text: 'Create Workspace',
                  onPressed: onCreateWorkspace,
                  icon: const Icon(Icons.add_rounded, size: 19, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
