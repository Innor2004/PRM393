import 'package:flutter/material.dart';

/// Utility class and widgets for responsive UI handling (PRM393 Standards).
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  // Screen Breakpoints
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 900;

  static bool isLaptop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200 &&
      MediaQuery.of(context).size.width < 1400;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1400;

  /// Returns recommended card grid column count based on available width.
  /// Standard PRM393:
  /// - Mobile (<600): 1
  /// - Tablet (600-899): 2-3
  /// - Laptop (900-1199): 4
  /// - Desktop (1200-1399): 4-5
  /// - Large Desktop (>=1400): 5-6
  static int getGridColumnCount(double width, {int maxColumns = 6}) {
    if (width < 600) return 1;
    if (width < 900) return 2;
    if (width < 1200) return 4;
    if (width < 1400) return 4;
    if (width < 1800) return 5;
    return maxColumns;
  }

  /// Calculates max cross axis extent for responsive grids
  static double getMaxCrossAxisExtent(double width) {
    if (width < 600) return width;
    if (width < 900) return 360;
    if (width < 1200) return 320;
    return 300;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// A container that centers child widget with max-width constraints on wide screens (2K/4K).
class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 1400,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.of(context).size.width;
    final responsivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: mediaWidth > 1400
              ? 32
              : mediaWidth > 900
                  ? 24
                  : 16,
          vertical: 16,
        );

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: responsivePadding,
          child: child,
        ),
      ),
    );
  }
}
