import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Playfair Display for serif headings, Inter for body. Matches HTML tokens.
abstract final class AppText {
  static TextStyle serif(double size, {FontWeight w = FontWeight.w700, Color c = AppColors.ink, double? h}) =>
      GoogleFonts.playfairDisplay(fontSize: size, fontWeight: w, color: c, height: h);

  static TextStyle sans(double size, {FontWeight w = FontWeight.w400, Color c = AppColors.body, double? h}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, color: c, height: h);

  static TextStyle get brand => serif(34, w: FontWeight.w800);
  static TextStyle get h2 => serif(21);
  static TextStyle get appBar => serif(16.5);
  static TextStyle get cardTitle => serif(13.5);
  static TextStyle get cardTitleSmall => serif(12.5);
  static TextStyle get sub => sans(11.5, c: AppColors.muted, h: 1.5);
  static TextStyle get sec => sans(11.5, w: FontWeight.w600, c: AppColors.sectionTitle);
  static TextStyle get secIn => sans(12, w: FontWeight.w600, c: AppColors.sectionTitle);
  static TextStyle get caps => sans(9, w: FontWeight.w700, c: AppColors.muted);
  static TextStyle get capsSpaced => sans(9, w: FontWeight.w700, c: AppColors.muted);
  static TextStyle get btn => sans(13.5, w: FontWeight.w600, c: Colors.white);
}
