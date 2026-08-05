/// Witchy application theme definitions.
/// Uses a witchy/earthy color palette: deep purples, warm pinks, earthy greens.
library;

import 'package:flutter/material.dart';

/// Light theme color scheme for Witchy.
class AppTheme {
  /// Light mode colors — deep purples, warm pinks, earthy greens.
  static const Color kPrimaryLight = Color(0xFF6A1B9A);

  /// Light mode secondary — warm pink.
  static const Color kSecondaryLight = Color(0xFFE91E8C);

  /// Light mode accent — earthy sage green.
  static const Color kAccentLight = Color(0xFF7CB342);

  /// Light mode background — warm cream.
  static const Color kBackgroundLight = Color(0xFFFFF8F0);

  /// Light mode surface — white.
  static const Color kSurfaceLight = Colors.white;

  /// Light mode text — deep charcoal.
  static const Color kTextLight = Color(0xFF2C1810);

  /// Light mode muted text.
  static const Color kMutedTextLight = Color(0xFF8D7B6E);

  /// Dark mode colors — deeper purples, rich pinks.
  static const Color kPrimaryDark = Color(0xFF9C4EC1);

  /// Dark mode secondary — vibrant pink.
  static const Color kSecondaryDark = Color(0xFFFF45A8);

  /// Dark mode accent — muted sage.
  static const Color kAccentDark = Color(0xFFA5D672);

  /// Dark mode background — deep charcoal.
  static const Color kBackgroundDark = Color(0xFF1A1420);

  /// Dark mode surface — dark purple-gray.
  static const Color kSurfaceDark = Color(0xFF2A2130);

  /// Dark mode text — warm white.
  static const Color kTextDark = Color(0xFFF5E6D3);

  /// Dark mode muted text.
  static const Color kMutedTextDark = Color(0xFFA89B8C);

  /// Period tracking color — pink.
  static const Color kPeriodColor = Color(0xFFE91E8C);

  /// Fertile window color — purple.
  static const Color kFertileColor = Color(0xFF9C27B0);

  /// Ovulation color — gold.
  static const Color kOvulationColor = Color(0xFFFFC107);

  /// Symptom tags color — teal.
  static const Color kSymptomColor = Color(0xFF009688);

  /// Light theme data.
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryLight,
          primary: kPrimaryLight,
          secondary: kSecondaryLight,
          surface: kSurfaceLight,
        ),
        scaffoldBackgroundColor: kBackgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurfaceLight,
          foregroundColor: kTextLight,
          elevation: 0,
        ),
        textTheme: _lightTextTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryLight,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD7CCC8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryLight, width: 2),
          ),
        ),
      );

  /// Dark theme data.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryDark,
          brightness: Brightness.dark,
          primary: kPrimaryDark,
          secondary: kSecondaryDark,
          surface: kSurfaceDark,
        ),
        scaffoldBackgroundColor: kBackgroundDark,
        appBarTheme: const AppBarTheme(
          backgroundColor: kSurfaceDark,
          foregroundColor: kTextDark,
          elevation: 0,
        ),
        textTheme: _darkTextTheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kPrimaryDark,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSurfaceDark,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4A3F50)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kPrimaryDark, width: 2),
          ),
        ),
      );

  /// Default light text theme.
  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: kTextLight,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: kTextLight,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: kTextLight,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: kTextLight,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: kMutedTextLight,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Default dark text theme.
  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 48,
      fontWeight: FontWeight.bold,
      color: kTextDark,
    ),
    headlineMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: kTextDark,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w500,
      color: kTextDark,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: kTextDark,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: kMutedTextDark,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
}
