import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildWitchyTheme() {
  final base = ThemeData(useMaterial3: true, scaffoldBackgroundColor: AppColors.bg);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pur).copyWith(
      primary: AppColors.pur,
      surface: AppColors.bg,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme),
    iconTheme: const IconThemeData(size: 20),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bg,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.playfairDisplay(
        fontSize: 16.5,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      iconTheme: const IconThemeData(color: AppColors.chipText),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.line),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.pur,
      unselectedItemColor: AppColors.navInactive,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
