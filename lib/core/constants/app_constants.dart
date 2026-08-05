/// Application-wide constants.
/// Follows the AGENTS.md convention: constants use kPascalCase naming.
library;

/// The display name of the application.
const String kAppTitle = 'Witchy';

/// Default average menstrual cycle length in days.
const int kDefaultCycleLength = 28;

/// Default average period duration in days.
const int kDefaultPeriodDuration = 5;

/// Minimum supported cycle length (days).
const int kMinCycleLength = 21;

/// Maximum supported cycle length (days).
const int kMaxCycleLength = 45;

/// Minimum average number of days to calculate a prediction.
const int kMinEntriesForPrediction = 2;

/// Ovulation offset — days before the next expected period.
const int kOvulationOffset = 14;

/// Fertile window length in days before ovulation.
const int kFertibleWindowDays = 6;

/// Maximum number of cycle entries to consider for rolling average.
const int kMaxEntriesForAverage = 5;

/// Onboarding completion flag used in shared_preferences.
const String kOnboardingCompleteKey = 'has_completed_onboarding';

/// Shared preferences key for user cycle length setting.
const String kCycleLengthKey = 'cycle_length';

/// Shared preferences key for user period duration setting.
const String kPeriodDurationKey = 'period_duration';

/// Shared preferences key for user's last period start date (ISO string).
const String kLastPeriodDateKey = 'last_period_date';
