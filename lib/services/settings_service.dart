import 'package:hive/hive.dart';
import '../models/user_settings.dart';

class SettingsService {
  static const String _settingsBoxName = 'user_settings';

  Future<UserSettings> getSettings() async {
    final box = await Hive.openBox<UserSettings>(_settingsBoxName);
    final settings = box.get('current');

    return settings ?? UserSettings();
  }

  Future<void> saveSettings(UserSettings settings) async {
    final box = await Hive.openBox<UserSettings>(_settingsBoxName);
    await box.put('current', settings);
  }

  Future<void> updateSetting({
    required String key,
    dynamic value,
  }) async {
    final settings = await getSettings();
    UserSettings updated;

    switch (key) {
      case 'averageCycleLength':
        updated = settings.copyWith(averageCycleLength: value as double);
      case 'averagePeriodDuration':
        updated = settings.copyWith(averagePeriodDuration: value as double);
      case 'notificationsEnabled':
        updated = settings.copyWith(notificationsEnabled: value as bool);
      case 'periodReminderTime':
        updated = settings.copyWith(periodReminderTime: value as String);
      case 'ovulationReminderTime':
        updated = settings.copyWith(ovulationReminderTime: value as String);
      case 'cycleLengthVariation':
        updated = settings.copyWith(cycleLengthVariation: value as double);
      case 'isPregnancyMode':
        updated = settings.copyWith(isPregnancyMode: value as bool);
      case 'pregnancyDueDate':
        updated = settings.copyWith(pregnancyDueDate: value as DateTime?);
      case 'preferredWeekStartDay':
        updated = settings.copyWith(preferredWeekStartDay: value as String);
      case 'anonymousMode':
        updated = settings.copyWith(anonymousMode: value as bool);
      default:
        return;
    }

    await saveSettings(updated);
  }
}
