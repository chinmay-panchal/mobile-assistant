import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Helper and layout utilities for responsive web, tablet, and mobile views.
class Responsive {
  static const double mobileBreakpoint = 650.0;
  static const double tabletBreakpoint = 1050.0;
  static const double maxContentWidth = 1200.0;
  static const double maxNarrowContentWidth = 840.0;
  static const double maxFormContentWidth = 480.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= mobileBreakpoint;

  /// Returns a responsive value depending on the current viewport width.
  static T value<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= tabletBreakpoint && desktop != null) {
      return desktop;
    }
    if (width >= mobileBreakpoint && tablet != null) {
      return tablet;
    }
    return mobile;
  }

  /// Calculates dynamic grid columns based on available width and target card min-width.
  static int getGridCrossAxisCount(
    BuildContext context, {
    double targetItemWidth = 260.0,
    int minColumns = 1,
    int maxColumns = 4,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    final int count = (width / targetItemWidth).floor();
    return count.clamp(minColumns, maxColumns);
  }
}

/// A wrapper that centers content horizontally and restricts it to a maximum width
/// on larger tablet/desktop displays to avoid stretched edge-to-edge layouts.
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = Responsive.maxContentWidth,
    this.padding,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isTablet = Responsive.isTablet(context);

    final defaultPadding = EdgeInsets.symmetric(
      horizontal: isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0),
    );

    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding ?? defaultPadding, child: child),
      ),
    );
  }
}

/// Displays either a centered dialog (on web and wide screens) or a bottom sheet (on mobile).
class AdaptiveModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget Function(BuildContext context, bool isDialog) builder,
    double maxWidth = 540.0,
    double maxHeightRatio = 0.88,
    bool barrierDismissible = true,
  }) {
    final bool useDialog = kIsWeb || Responsive.isWide(context);

    if (useDialog) {
      return showDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (dialogContext) {
          final screenHeight = MediaQuery.sizeOf(dialogContext).height;
          final maxH = screenHeight * maxHeightRatio;
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            elevation: 0,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxH),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Material(
                  color: Colors.transparent,
                  child: builder(dialogContext, true),
                ),
              ),
            ),
          );
        },
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => builder(sheetContext, false),
      );
    }
  }
}

/// Constrains a bottom sheet or dialog to look like a polished centered modal card on web/desktop.
class ResponsiveModalWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveModalWrapper({
    super.key,
    required this.child,
    this.maxWidth = 540.0,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = Responsive.isWide(context);
    if (!isWide) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
      ),
    );
  }
}
