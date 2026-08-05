import 'package:flutter/foundation.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _settingsService = SettingsService();
  UserSettings _settings = UserSettings();
  bool _isLoading = true;

  UserSettings get settings => _settings;

  bool get isLoading => _isLoading;

  double get averageCycleLength => _settings.averageCycleLength;

  double get averagePeriodDuration => _settings.averagePeriodDuration;

  bool get notificationsEnabled => _settings.notificationsEnabled;

  bool get isPregnancyMode => _settings.isPregnancyMode;

  bool get anonymousMode => _settings.anonymousMode;

  Future<void> initialize() async {
    _settings = await _settingsService.getSettings();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateSetting({
    required String key,
    dynamic value,
  }) async {
    await _settingsService.updateSetting(key: key, value: value);
    await initialize();
  }

  Future<void> setAverageCycleLength(double length) async {
    await updateSetting(key: 'averageCycleLength', value: length);
  }

  Future<void> setAveragePeriodDuration(double duration) async {
    await updateSetting(key: 'averagePeriodDuration', value: duration);
  }

  Future<void> toggleNotifications(bool enabled) async {
    await updateSetting(key: 'notificationsEnabled', value: enabled);
  }

  Future<void> togglePregnancyMode(bool enabled) async {
    await updateSetting(key: 'isPregnancyMode', value: enabled);
  }

  Future<void> setAnonymousMode(bool mode) async {
    await updateSetting(key: 'anonymousMode', value: mode);
  }

  Future<void> setPregnancyDueDate(DateTime? dueDate) async {
    await updateSetting(key: 'pregnancyDueDate', value: dueDate);
  }
}
