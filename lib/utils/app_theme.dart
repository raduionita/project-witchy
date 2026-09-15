import 'package:flutter/material.dart';

/// Central design tokens for the Witchy app.
///
/// Palette, type, radii and elevation follow DESIGN.md v2.1 §2 verbatim:
/// Deep Purple `#3B0066` primary, Light Lavender `#E0D4EA` fertile fills,
/// Soft Coral `#FFB7B2` ovulation peaks, `#F8F6FA` canvas, `#333333` /
/// `#666666` text, `#E0E0E0` borders. System sans throughout, no serif.
abstract class AppColors {
  static const Color kPrimary = Color(0xFF3B0066);
  static const Color kPrimaryLight = Color(0xFF5E2A84);
  static const Color kPrimaryLighter = Color(0xFF8154A2);
  static const Color kPrimaryLightest = Color(0xFFE0D4EA);
  static const Color kCoral = Color(0xFFFFB7B2);
  static const Color kCanvas = Color(0xFFF8F6FA);
  static const Color kSurfaceBase = Color(0xFFFFFFFF);
  static const Color kTextPrimary = Color(0xFF333333);
  static const Color kTextSecondary = Color(0xFF666666);
  static const Color kBorder = Color(0xFFE0E0E0);
  static const Color kError = Color(0xFFB3261E);

  static const Color kCyclePeriod = Color(0xFF3B0066);
  static const Color kCycleFertile = Color(0xFFE0D4EA);
  static const Color kCycleOvulation = Color(0xFFFFB7B2);
}

abstract class AppSpacing {
  static const double kXs = 4;
  static const double kSm = 8;
  static const double kMd = 16;
  static const double kLg = 24;
  static const double kXl = 32;
  static const double kScreenMargin = 20;
  static const double kSectionGap = 24;
  static const double kBottomPadding = 96;
  static const double kRadiusS = 8;
  static const double kRadiusM = 15;
  static const double kRadiusInput = 12;
  static const double kRadiusButton = 25;
  static const double kRadiusPill = 20;
  static const double kRadiusCircle = 999;
  static const double kDayCell = 30;
  static const double kLegendDot = 10;
}

abstract class AppSizing {
  static const double kXs = 4;
  static const double kSm = 8;
  static const double kMd = 16;
  static const double kLg = 24;
  static const double kXl = 32;
  static const double kXl2 = 34;
  static const double kXl4 = 36;
  static const double kXl8 = 40;
  static const double kXxl = 48;
  static const double kMinTouch = 48;
  static const double kNavHeight = 64;
  static const double kHeroDial = 220;
  static const double kCycleCircle = 180;
  static const double kLogoCircle = 120;
  static const double kToggleW = 50;
  static const double kToggleH = 24;
  static const double kToggleThumb = 20;
}

abstract class AppTypography {
  static const double kDisplayL = 32;
  static const double kDisplayM = 44;
  static const double kH1 = 18;
  static const double kH2 = 22;
  static const double kH3 = 16;
  static const double kBodyL = 15;
  static const double kBodyM = 14;
  static const double kButton = 16;
  static const double kCaption = 12;
  static const double kNavLabel = 10;
}

abstract class AppShadows {
  static const List<BoxShadow> kCard = [BoxShadow(color: Color(0x05000000), offset: Offset(0, 2), blurRadius: 5)];
  static const List<BoxShadow> kHero = [BoxShadow(color: Color(0x0D000000), offset: Offset(0, 4), blurRadius: 10)];
}

abstract class AppBreakpoints {
  static const double kMaxContentWidth = 480;
}

abstract class AppTheme {
  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: AppTypography.kDisplayL, height: 1.20, color: color),
      displayMedium: TextStyle(fontWeight: FontWeight.w700, fontSize: AppTypography.kDisplayM, height: 1.10, color: color),
      displaySmall: TextStyle(fontWeight: FontWeight.w700, fontSize: AppTypography.kH2, height: 1.30, color: color),
      headlineLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kH1, height: 1.30, color: color),
      headlineMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kH1, height: 1.30, color: color),
      headlineSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: AppTypography.kH3, height: 1.40, color: color),
      titleLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kBodyL, height: 1.50, color: color),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kBodyM, height: 1.40, color: color),
      titleSmall: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, height: 1.45, color: color),
      bodyLarge: TextStyle(fontWeight: FontWeight.w400, fontSize: AppTypography.kBodyL, height: 1.50, color: color),
      bodyMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: AppTypography.kBodyM, height: 1.40, color: color),
      bodySmall: TextStyle(fontWeight: FontWeight.w400, fontSize: AppTypography.kCaption, height: 1.40, color: color),
      labelLarge: TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kButton, height: 1.00, color: color),
      labelMedium: TextStyle(fontWeight: FontWeight.w400, fontSize: AppTypography.kCaption, height: 1.40, color: color),
      labelSmall: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, height: 1.30, letterSpacing: 0.88, color: color),
    );
  }

  static ThemeData _base(ThemeData theme, ColorScheme scheme) {
    return theme.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.kSurfaceBase,
        foregroundColor: AppColors.kTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kH1, color: AppColors.kTextPrimary),
        iconTheme: const IconThemeData(size: 20, color: AppColors.kTextPrimary),
        actionsIconTheme: const IconThemeData(size: 20, color: AppColors.kTextPrimary),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: AppColors.kSurfaceBase,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppSpacing.kRadiusM))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.kCanvas,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusInput), borderSide: const BorderSide(color: AppColors.kBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusInput), borderSide: const BorderSide(color: AppColors.kBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusInput), borderSide: const BorderSide(color: AppColors.kPrimary, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.kPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(AppSizing.kMinTouch),
          padding: const EdgeInsets.all(15),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kButton),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.kPrimary,
          minimumSize: const Size.fromHeight(AppSizing.kMinTouch),
          padding: const EdgeInsets.all(15),
          side: const BorderSide(color: AppColors.kPrimary),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: AppTypography.kButton),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusButton)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.kPrimary, minimumSize: const Size(AppSizing.kMinTouch, AppSizing.kMinTouch)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) => s.contains(WidgetState.selected) ? Colors.white : Colors.white),
        trackColor: WidgetStateProperty.resolveWith((Set<WidgetState> s) => s.contains(WidgetState.selected) ? AppColors.kPrimary : AppColors.kBorder),
      ),
      sliderTheme: const SliderThemeData(
        trackHeight: 6,
        activeTrackColor: AppColors.kPrimary,
        inactiveTrackColor: AppColors.kPrimaryLightest,
        thumbColor: AppColors.kPrimary,
        overlayColor: Color(0x263B0066),
      ),
      chipTheme: theme.chipTheme.copyWith(
        backgroundColor: AppColors.kSurfaceBase,
        selectedColor: AppColors.kPrimary,
        secondarySelectedColor: AppColors.kPrimary,
        checkmarkColor: Colors.white,
        side: const BorderSide(color: AppColors.kBorder),
        labelStyle: const TextStyle(fontSize: AppTypography.kBodyM, color: AppColors.kTextPrimary),
        secondaryLabelStyle: const TextStyle(fontSize: AppTypography.kBodyM, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.kRadiusPill)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.kSurfaceBase,
        selectedItemColor: AppColors.kPrimary,
        unselectedItemColor: AppColors.kTextSecondary,
        selectedLabelStyle: TextStyle(fontSize: AppTypography.kNavLabel),
        unselectedLabelStyle: TextStyle(fontSize: AppTypography.kNavLabel),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(backgroundColor: AppColors.kSurfaceBase, indicatorColor: AppColors.kPrimaryLightest, height: 68),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  static ThemeData light() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: AppColors.kPrimary, brightness: Brightness.light).copyWith(
      primary: AppColors.kPrimary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.kPrimaryLightest,
      onPrimaryContainer: AppColors.kPrimary,
      secondary: AppColors.kPrimaryLight,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.kPrimaryLightest,
      onSecondaryContainer: AppColors.kPrimary,
      tertiary: AppColors.kCoral,
      onTertiary: AppColors.kPrimary,
      tertiaryContainer: AppColors.kCoral,
      onTertiaryContainer: AppColors.kPrimary,
      surface: AppColors.kCanvas,
      onSurface: AppColors.kTextPrimary,
      onSurfaceVariant: AppColors.kTextSecondary,
      surfaceContainerLow: AppColors.kSurfaceBase,
      surfaceContainerHighest: AppColors.kCanvas,
      error: AppColors.kError,
      onError: Colors.white,
      outline: AppColors.kBorder,
      outlineVariant: AppColors.kBorder,
    );
    final ThemeData base = ThemeData(colorScheme: colorScheme, brightness: Brightness.light);
    return _base(base, colorScheme).copyWith(
      textTheme: _textTheme(AppColors.kTextPrimary),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.kPrimary, selectionColor: Color(0x553B0066), selectionHandleColor: AppColors.kPrimary),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: AppColors.kPrimary, borderRadius: BorderRadius.circular(AppSpacing.kRadiusS)),
        textStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  static ThemeData dark() {
    final ColorScheme colorScheme = ColorScheme.fromSeed(seedColor: AppColors.kPrimary, brightness: Brightness.dark).copyWith(
      primary: const Color(0xFFC9B6E3),
      onPrimary: const Color(0xFF2A0A4A),
      primaryContainer: AppColors.kPrimaryLight,
      onPrimaryContainer: AppColors.kPrimaryLightest,
      secondary: const Color(0xFFC9B6E3),
      onSecondary: const Color(0xFF2A0A4A),
      secondaryContainer: const Color(0xFF4A3468),
      onSecondaryContainer: AppColors.kPrimaryLightest,
      tertiary: AppColors.kCoral,
      onTertiary: const Color(0xFF4A1A18),
      tertiaryContainer: const Color(0xFF7F2A33),
      onTertiaryContainer: const Color(0xFFFFDAD9),
      surface: const Color(0xFF1B1430),
      onSurface: const Color(0xFFF0EAF8),
      onSurfaceVariant: const Color(0xFFCFC6DE),
      surfaceContainerLow: const Color(0xFF241B3B),
      surfaceContainerHighest: const Color(0xFF332A4C),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      errorContainer: const Color(0xFF93000A),
      onErrorContainer: const Color(0xFFFFDAD6),
      outline: const Color(0xFF6A5E80),
      outlineVariant: const Color(0xFF4A4060),
    );
    final ThemeData base = ThemeData(colorScheme: colorScheme, brightness: Brightness.dark);
    return _base(base, colorScheme).copyWith(
      textTheme: _textTheme(const Color(0xFFF0EAF8)),
      textSelectionTheme: const TextSelectionThemeData(cursorColor: Color(0xFFC9B6E3), selectionColor: Color(0x55C9B6E3), selectionHandleColor: Color(0xFFC9B6E3)),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(color: const Color(0xFFF0EAF8), borderRadius: BorderRadius.circular(AppSpacing.kRadiusS)),
        textStyle: const TextStyle(color: Color(0xFF1B1430)),
      ),
    );
  }
}
