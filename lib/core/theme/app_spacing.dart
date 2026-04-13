import 'package:flutter/material.dart';

/// EduAccess Design System — Spacing constants
/// Use these instead of raw numbers. Exception: 0 is acceptable.
abstract final class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 24.0;
  static const double xxl  = 32.0;
  static const double xxxl = 48.0;

  // ── Common edge insets ────────────────────────────────────────────────────
  static const EdgeInsets pagePadding = EdgeInsets.all(xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(xl);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
}

/// EduAccess Design System — Border-radius constants
/// Use Radius.* values inside BorderRadius.
abstract final class AppRadius {
  static const Radius sm   = Radius.circular(6.0);
  static const Radius md   = Radius.circular(10.0);
  static const Radius lg   = Radius.circular(12.0);
  static const Radius xl   = Radius.circular(16.0);
  static const Radius pill = Radius.circular(100.0);

  // ── BorderRadius convenience ───────────────────────────────────────────────
  static const BorderRadius smAll   = BorderRadius.all(sm);
  static const BorderRadius mdAll   = BorderRadius.all(md);
  static const BorderRadius lgAll   = BorderRadius.all(lg);
  static const BorderRadius xlAll   = BorderRadius.all(xl);
  static const BorderRadius pillAll = BorderRadius.all(pill);
}

/// EduAccess Design System — Common box shadows
abstract final class AppShadows {
  /// Subtle card shadow — used for AppCard and stat cards
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000), // black ~4%
      blurRadius: 12,
      offset: Offset(0, 2),
    ),
  ];

  /// Topbar shadow
  static const List<BoxShadow> topbar = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Dropdown/dialog shadow
  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1A000000), // black ~10%
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
