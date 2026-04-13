import 'package:flutter/material.dart';

/// EduAccess responsive breakpoints.
///
/// Usage:
/// ```dart
/// if (Responsive.isDesktop(context)) { ... }
///
/// Responsive.value(
///   context,
///   mobile: 12.0,
///   tablet: 16.0,
///   desktop: 24.0,
/// )
///
/// // Inside build:
/// final screen = Responsive.of(context);
/// if (screen.isMobile) ...
/// ```
class Responsive {
  // ── Breakpoints ─────────────────────────────────────────────────────────────
  static const double mobileMaxWidth  = 767;
  static const double tabletMinWidth  = 768;
  static const double tabletMaxWidth  = 1023;
  static const double desktopMinWidth = 1024;

  // ── Static helpers ───────────────────────────────────────────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileMaxWidth;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return w >= tabletMinWidth && w <= tabletMaxWidth;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopMinWidth;

  static bool isMobileOrTablet(BuildContext context) =>
      !isDesktop(context);

  /// Returns a value based on current screen size.
  /// Cascades: desktop → tablet (if not set, falls back to desktop) → mobile.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }

  /// Returns a snapshot of the current screen class.
  static ResponsiveInfo of(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ResponsiveInfo(width);
  }

  /// Content width inside the sidebar layout (for desktop).
  static double contentWidth(BuildContext context) =>
      MediaQuery.of(context).size.width - 240; // subtract sidebar
}

/// Snapshot of responsive state — cache this in build() for performance.
class ResponsiveInfo {
  final double width;

  const ResponsiveInfo(this.width);

  bool get isMobile  => width <= Responsive.mobileMaxWidth;
  bool get isTablet  => width >= Responsive.tabletMinWidth && width <= Responsive.tabletMaxWidth;
  bool get isDesktop => width >= Responsive.desktopMinWidth;
  bool get isCompact => width <= Responsive.tabletMaxWidth;

  /// Sidebar 240px permanent on desktop, hidden on mobile/tablet.
  bool get hasPermanentSidebar => isDesktop;

  /// Show bottom navigation bar.
  bool get hasBottomNav => isMobile;
}

/// Responsive builder widget — rebuilds on breakpoint change.
///
/// ```dart
/// ResponsiveBuilder(
///   mobile:  (ctx) => MobileLayout(),
///   tablet:  (ctx) => TabletLayout(),
///   desktop: (ctx) => DesktopLayout(),
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext) mobile;
  final Widget Function(BuildContext)? tablet;
  final Widget Function(BuildContext) desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screen = Responsive.of(context);
    if (screen.isDesktop) return desktop(context);
    if (screen.isTablet && tablet != null) return tablet!(context);
    return mobile(context);
  }
}
