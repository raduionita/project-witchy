/// User profile model for Witchy.
/// Holds anonymous user settings and preferences.
library;

class UserProfile {
  /// Creates a new user profile with the given settings.
  const UserProfile({
    this.cycleLengthDays = 28,
    this.periodDurationDays = 5,
    this.lastPeriodDate,
    this.notificationsEnabled = true,
  });

  /// Average cycle length in days. Default is 28.
  final int cycleLengthDays;

  /// Average period duration in days. Default is 5.
  final int periodDurationDays;

  /// The start date of the last recorded period, if any.
  final DateTime? lastPeriodDate;

  /// Whether push/local notifications are enabled.
  final bool notificationsEnabled;

  /// Creates a copy of this profile with the given fields replaced.
  UserProfile copyWith({
    int? cycleLengthDays,
    int? periodDurationDays,
    DateTime? lastPeriodDate,
    bool? notificationsEnabled,
  }) {
    return UserProfile(
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      periodDurationDays: periodDurationDays ?? this.periodDurationDays,
      lastPeriodDate: lastPeriodDate ?? this.lastPeriodDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  /// Serializes the profile to a map for storage.
  Map<String, dynamic> toJson() {
    return {
      'cycle_length': cycleLengthDays,
      'period_duration': periodDurationDays,
      'last_period_date': lastPeriodDate?.toIso8601String(),
      'notifications_enabled': notificationsEnabled,
    };
  }

  /// Creates a UserProfile from a JSON map.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      cycleLengthDays: json['cycle_length'] as int? ?? 28,
      periodDurationDays: json['period_duration'] as int? ?? 5,
      lastPeriodDate: json['last_period_date'] != null
          ? DateTime.parse(json['last_period_date'] as String)
          : null,
      notificationsEnabled: json['notifications_enabled'] as bool? ?? true,
    );
  }

  @override
  String toString() {
    return 'UserProfile(cycleLengthDays: $cycleLengthDays, periodDurationDays: $periodDurationDays, lastPeriodDate: $lastPeriodDate)';
  }
}
