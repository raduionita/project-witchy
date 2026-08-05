/// Storage service for Witchy.
/// Wraps shared_preferences for simple key-value storage of user settings.
library;

import 'package:shared_preferences/shared_preferences.dart';

/// Service for reading and writing persistent app settings.
class StorageService {
  /// Creates a new storage service instance.
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  late final SharedPreferences _prefs;

  /// Returns whether onboarding has been completed.
  Future<bool> isOnboardingComplete() async {
    return _prefs.getBool('has_completed_onboarding') ?? false;
  }

  /// Marks onboarding as complete.
  Future<void> setOnboardingComplete() async {
    await _prefs.setBool('has_completed_onboarding', true);
  }

  /// Returns the user's cycle length, or null if not set.
  Future<int?> getCycleLength() async {
    return _prefs.getInt('cycle_length');
  }

  /// Saves the user's cycle length.
  Future<void> setCycleLength(int value) async {
    await _prefs.setInt('cycle_length', value);
  }

  /// Returns the user's period duration, or null if not set.
  Future<int?> getPeriodDuration() async {
    return _prefs.getInt('period_duration');
  }

  /// Saves the user's period duration.
  Future<void> setPeriodDuration(int value) async {
    await _prefs.setInt('period_duration', value);
  }

  /// Returns the last period start date as ISO string, or null.
  Future<String?> getLastPeriodDate() async {
    return _prefs.getString('last_period_date');
  }

  /// Saves the last period start date as ISO string.
  Future<void> setLastPeriodDate(String isoString) async {
    await _prefs.setString('last_period_date', isoString);
  }

  /// Returns whether notifications are enabled.
  Future<bool> isNotificationsEnabled() async {
    return _prefs.getBool('notifications_enabled') ?? true;
  }

  /// Saves whether notifications are enabled.
  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool('notifications_enabled', value);
  }

  /// Returns all logged period entries as a JSON array string.
  Future<String?> getEntries() async {
    return _prefs.getString('period_entries');
  }

  /// Saves all period entries as a JSON array string.
  Future<void> setEntries(String jsonValue) async {
    await _prefs.setString('period_entries', jsonValue);
  }

  /// Clears all stored data. Useful for testing or resetting the app.
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
