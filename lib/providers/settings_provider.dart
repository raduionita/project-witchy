import 'package:flutter/material.dart';

import '../models/cycle_goal.dart';
import '../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._prefs, {
    this.lunarNotifications = true,
    this.darkMode = false,
    this.goal = CycleGoal.track,
  });

  final PrefsService _prefs;
  bool lunarNotifications;
  bool darkMode;
  CycleGoal goal;

  static Future<SettingsProvider> load(PrefsService prefs) async {
    await prefs.clearLegacyBindingFlags();
    return SettingsProvider(
      prefs,
      lunarNotifications: await prefs.lunarNotifications(),
      darkMode: await prefs.darkMode(),
      goal: await prefs.goal(),
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

  void setGoal(CycleGoal value) {
    goal = value;
    notifyListeners();
    _prefs.setGoal(value);
  }

  /// In-memory reset after Delete All Data (prefs already wiped).
  void resetToDefaults() {
    lunarNotifications = true;
    darkMode = false;
    goal = CycleGoal.track;
    notifyListeners();
  }
}
