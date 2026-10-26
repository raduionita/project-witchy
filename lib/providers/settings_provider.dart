import 'package:flutter/material.dart';

import '../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._prefs, {
    this.lunarNotifications = true,
    this.darkMode = false,
    this.startTab = 0,
  });

  final PrefsService _prefs;
  bool lunarNotifications;
  bool darkMode;
  int startTab;

  static Future<SettingsProvider> load(PrefsService prefs) async {
    await prefs.clearLegacyBindingFlags();
    return SettingsProvider(
      prefs,
      lunarNotifications: await prefs.lunarNotifications(),
      darkMode: await prefs.darkMode(),
      startTab: await prefs.startTab(),
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

  void setStartTab(int v) {
    startTab = v.clamp(0, 3);
    notifyListeners();
    _prefs.setStartTab(startTab);
  }

  /// In-memory reset after Delete All Data (prefs already wiped).
  void resetToDefaults() {
    lunarNotifications = true;
    darkMode = false;
    startTab = 0;
    notifyListeners();
  }
}
