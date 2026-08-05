import 'package:flutter/foundation.dart';

/// Manages user settings and preferences.
class SettingsProvider extends ChangeNotifier {
  bool _notificationsEnabled = false;
  bool get notificationsEnabled => _notificationsEnabled;

  int _reminderTime = 8; // 8 AM default
  int get reminderTime => _reminderTime;

  bool _isAnonymous = false;
  bool get isAnonymous => _isAnonymous;

  String _userName = '';
  String get userName => _userName;

  /// Toggles notifications on/off.
  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
  }

  /// Sets the reminder time.
  void setReminderTime(int hour) {
    _reminderTime = hour;
    notifyListeners();
  }

  /// Sets the user name.
  void setUserName(String name) {
    _userName = name;
    notifyListeners();
  }

  /// Toggles anonymous mode.
  void setAnonymous(bool anonymous) {
    _isAnonymous = anonymous;
    notifyListeners();
  }

  /// Resets all settings to defaults.
  void resetToDefaults() {
    _notificationsEnabled = false;
    _reminderTime = 8;
    _isAnonymous = false;
    _userName = '';
    notifyListeners();
  }
}