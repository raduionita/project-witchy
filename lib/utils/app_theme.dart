import 'package:flutter/material.dart';

/// Central design tokens for the Witchy app.
abstract class AppColors {
  static const Color kPrimary = Color(0xFF8E44AD);
  static const Color kSecondary = Color(0xFFF39C12);
  static const Color kTertiary = Color(0xFFE91E63);
  static const Color kSurface = Color(0xFFFFF8FB);
  static const Color kError = Color(0xFFB00020);
}

abstract class AppSpacing {
  static const double kXs = 4;
  static const double kSm = 8;
  static const double kMd = 16;
  static const double kLg = 24;
  static const double kXl = 32;
  static const double kRadiusSm = 8;
  static const double kRadiusMd = 16;
  static const double kRadiusLg = 24;
  static const double kRadiusXl = 32;
}

abstract class AppTypography {
  static const String kFontFamily = 'SF Pro Display';
}

/// Builds the Witchy [ThemeData] for light and dark modes.
abstract class AppTheme {
  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.kPrimary,
      brightness: Brightness.light,
    ).copyWith(primary: AppColors.kPrimary, secondary: AppColors.kSecondary, tertiary: AppColors.kTertiary, surface: AppColors.kSurface, error: AppColors.kError);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.kFontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(backgroundColor: colorScheme.surface, foregroundColor: colorScheme.onSurface, elevation: 0),
      cardTheme: const CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSpacing.kRadiusMd)))),
    );
  }

  static ThemeData dark() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.kPrimary,
      brightness: Brightness.dark,
    ).copyWith(primary: AppColors.kPrimary, secondary: AppColors.kSecondary, tertiary: AppColors.kTertiary, error: AppColors.kError);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: AppTypography.kFontFamily,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(backgroundColor: colorScheme.surface, foregroundColor: colorScheme.onSurface, elevation: 0),
      cardTheme: const CardThemeData(elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSpacing.kRadiusMd)))),
    );
  }
}
