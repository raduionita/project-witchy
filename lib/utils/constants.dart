// Color scheme for Witchy app
class AppColors {
  static const primary = Color(0xFF7B1FA2); // Deep purple
  static const primaryLight = Color(0xFF9C27B0);
  static const primaryDark = Color(0xFF4A148C);
  
  static const secondary = Color(0xFF42A5F5); // Blue for fertility
  static const secondaryLight = Color(0xFF64B5F6);
  
  static const success = Color(0xFF2E7D32); // Green for healthy
  static const warning = Color(0xFFFF9800); // Orange for attention
  static const error = Color(0xFFD32F2F); // Red for issues
  
  static const background = Color(0xFFF5F5FF);
  static const surface = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF212121);
  static const textSecondary = Color(0xFF757575);
}

// App theme configuration
class AppTheme {
  static const String fontFamily = 'Inter'; // Clean, modern font
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  static const int fontSizeSmall = 12;
  static const int fontSizeMedium = 14;
  static const int fontSizeLarge = 16;
  static const int fontSizeTitle = 20;
  
  static const int spacingSmall = 8;
  static const int spacingMedium = 16;
  static const int spacingLarge = 24;
}

// Cycle phase constants
enum CyclePhase {
  premenstrual,
  menstruation,
  follicular,
  ovulation,
  luteal,
  unknown,
}

// Symptom types for tracking
enum SymptomType {
  cramps,
  bloating,
  breastTenderness,
  moodChanges,
  fatigue,
  headaches,
  sleepIssues,
}

// Cycle entry types
enum EntryType {
  periodStart,
  periodEnd,
  ovulation,
  pregnancyTest,
  other,
}
