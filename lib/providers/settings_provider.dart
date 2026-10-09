import 'package:flutter/material.dart';

import '../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._prefs, {
    this.lunarNotifications = true,
    this.darkMode = false,
  });

  final PrefsService _prefs;
  bool lunarNotifications;
  bool darkMode;

  static Future<SettingsProvider> load(PrefsService prefs) async {
    await prefs.clearLegacyBindingFlags();
    return SettingsProvider(
      prefs,
      lunarNotifications: await prefs.lunarNotifications(),
      darkMode: await prefs.darkMode(),
    );
  }

  void setLunar(bool v) {
    lunarNotifications = v;
    notifyListeners();
    _prefs.setLunarNotifications(v);
  }

  void setDark(bool v) {
    darkMode = v;
    notifyListeners();
    _prefs.setDarkMode(v);
  }
}
