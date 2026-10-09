import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Builds the app theme for [brightness]. Flips [AppColors.dark] first so
/// every token getter resolves to the matching light/dark value.
ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  AppColors.dark = brightness == Brightness.dark;
  final base = ThemeData(useMaterial3: true, brightness: brightness, scaffoldBackgroundColor: AppColors.bg);
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.pur, brightness: brightness).copyWith(
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
      iconTheme: IconThemeData(color: AppColors.chipText),
    ),
    cardTheme: CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: AppColors.line),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.pur,
      unselectedItemColor: AppColors.navInactive,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
  );
}
