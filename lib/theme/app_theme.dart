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
      backgroundColor: AppColors.navBar,
      selectedItemColor: AppColors.pur,
      unselectedItemColor: AppColors.navInactive,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    // Shared component theming so one-off widgets (sheets, dialogs, forms)
    // stay on the token palette in both brightnesses without per-call styling.
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.fieldBg,
      hintStyle: TextStyle(color: AppColors.placeholder),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.line)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.line)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.pur)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? Colors.white : AppColors.card),
      trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.pur : AppColors.switchOff),
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.pur : Colors.transparent),
      checkColor: const WidgetStatePropertyAll(Colors.white),
      side: BorderSide(color: AppColors.line, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      titleTextStyle: GoogleFonts.playfairDisplay(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.ink),
      contentTextStyle: GoogleFonts.inter(fontSize: 12.5, color: AppColors.body),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.dark ? AppColors.lav2 : AppColors.plum,
      contentTextStyle: GoogleFonts.inter(fontSize: 12, color: Colors.white),
      actionTextColor: AppColors.gold,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.pur,
      inactiveTrackColor: AppColors.sliderTrack,
      thumbColor: Colors.white,
      overlayShape: SliderComponentShape.noOverlay,
      trackHeight: 4,
    ),
    dividerTheme: DividerThemeData(color: AppColors.line, thickness: 1),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: AppColors.bg, surfaceTintColor: Colors.transparent, modalBackgroundColor: AppColors.bg),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.pur)),
  );
}
