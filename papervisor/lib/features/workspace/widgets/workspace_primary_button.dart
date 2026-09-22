import 'package:flutter/material.dart';
import '../constants/workspace_theme.dart';

/// Tactile, premium call-to-action button for the Workspace system.
/// Features Obsidian Slate authority, clean typography, and tactile press scaling.
class WorkspacePrimaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final bool isSecondary;
  final bool isDestructive;
  final double height;

  const WorkspacePrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.isSecondary = false,
    this.isDestructive = false,
    this.height = 48.0,
  });

  @override
  State<WorkspacePrimaryButton> createState() => _WorkspacePrimaryButtonState();
}

class _WorkspacePrimaryButtonState extends State<WorkspacePrimaryButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;
    List<BoxShadow> shadows = [];

    if (widget.isDestructive) {
      bgColor = _isEnabled ? WorkspaceTheme.error : WorkspaceTheme.borderSubtle;
      textColor = Colors.white;
      if (_isEnabled) {
        shadows = [
          BoxShadow(
            color: WorkspaceTheme.error.withValues(alpha: 0.25),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ];
      }
    } else if (widget.isSecondary) {
      bgColor = WorkspaceTheme.surfaceWhite;
      textColor = WorkspaceTheme.textPrimary;
      border = Border.all(color: WorkspaceTheme.borderSubtle, width: 1.2);
    } else {
      // Primary Obsidian Slate
      bgColor = _isEnabled ? WorkspaceTheme.primaryDark : WorkspaceTheme.borderSubtle;
      textColor = _isEnabled ? Colors.white : WorkspaceTheme.textMuted;
      border = _isEnabled ? Border.all(color: WorkspaceTheme.primaryBorder) : null;
      if (_isEnabled) {
        shadows = WorkspaceTheme.fabShadow;
      }
    }

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
          border: border,
          boxShadow: shadows,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(WorkspaceTheme.radiusPill),
            onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
            onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
            onTapCancel: _isEnabled ? () => setState(() => _isPressed = false) : null,
            onTap: _isEnabled ? widget.onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isSecondary ? WorkspaceTheme.primaryDark : Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            widget.icon!,
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              widget.text,
                              style: TextStyle(
                                fontFamily: WorkspaceTheme.fontFamily,
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
