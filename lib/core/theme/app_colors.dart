import 'package:flutter/material.dart';

/// EduAccess Design System — Color Palette
/// Never use raw hex values in widgets. Always reference AppColors.*
abstract final class AppColors {
  // ── Primary — Deep Emerald ─────────────────────────────────────────────────
  static const Color primary900 = Color(0xFF112032); // sidebar bg
  static const Color primary700 = Color(0xFF2D6A4F); // active nav, primary buttons
  static const Color primary500 = Color(0xFF52B788); // icons, accents
  static const Color primary300 = Color(0xFF95D5B2); // light accents
  static const Color primary100 = Color(0xFFE0F5EB); // badge bg, card tint

  // ── Accent — Warm Orange ───────────────────────────────────────────────────
  static const Color accent700 = Color(0xFFCB6219); // strong CTA text
  static const Color accent500 = Color(0xFFF4A261); // CTA buttons, nav accent bar
  static const Color accent100 = Color(0xFFFFE9DA); // accent badge bg

  // ── Neutral ────────────────────────────────────────────────────────────────
  static const Color neutral900 = Color(0xFF1A1A1E); // primary text
  static const Color neutral700 = Color(0xFF4C5563); // secondary text
  static const Color neutral500 = Color(0xFF6B7280); // muted text, subtitle
  static const Color neutral300 = Color(0xFFBCC2CC); // borders, dividers
  static const Color neutral100 = Color(0xFFEEF0F5); // chip bg, icon button bg
  static const Color neutral50  = Color(0xFFF8FAF9); // table alt row, card bg

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
  static const Color info    = Color(0xFF3B82F6);

  // ── Surface ────────────────────────────────────────────────────────────────
  static const Color white  = Color(0xFFFFFFFF);
  static const Color bgPage = Color(0xFFF7FAF8); // page / content background

  // ── Sidebar-specific ──────────────────────────────────────────────────────
  /// Inactive sidebar nav text: #99C7B1
  static const Color sidebarNavText = Color(0xFF99C7B1);
  /// Sidebar section label: #73A68C
  static const Color sidebarSectionLabel = Color(0xFF73A68C);
  /// Sidebar divider: #264D39
  static const Color sidebarDivider = Color(0xFF264D39);
}
