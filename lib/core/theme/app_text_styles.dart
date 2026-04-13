import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// EduAccess Design System — Typography
/// Font: Inter (loaded via google_fonts)
/// Never hardcode font sizes or weights. Always use AppTextStyles.*
abstract final class AppTextStyles {
  // ── Headings ───────────────────────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.25,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      );

  static TextStyle get h4 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
      );

  // ── Body ───────────────────────────────────────────────────────────────────
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        height: 1.5,
      );

  // ── Label / Caption ────────────────────────────────────────────────────────
  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        height: 1.4,
      );

  // ── Sidebar section label ─────────────────────────────────────────────────
  static TextStyle get sidebarSection => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        height: 1.4,
      );

  // ── Convenience: semibold variants ────────────────────────────────────────
  static TextStyle get bodyMdSemiBold => bodyMd.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get bodySmSemiBold => bodySm.copyWith(fontWeight: FontWeight.w600);
  static TextStyle get bodyLgSemiBold => bodyLg.copyWith(fontWeight: FontWeight.w600);
}
