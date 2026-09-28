import 'package:flutter/material.dart';

import '../services/prefs_service.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider(
    this._prefs, {
    this.lunarNotifications = true,
    this.darkMode = false,
    this.shareBleed = true,
    this.shareFertile = true,
    this.shareSymptoms = false,
  });

  final PrefsService _prefs;
  bool lunarNotifications;
  bool darkMode;
  bool shareBleed;
  bool shareFertile;
  bool shareSymptoms;

  static Future<SettingsProvider> load(PrefsService prefs) async => SettingsProvider(
    prefs,
    lunarNotifications: await prefs.lunarNotifications(),
    darkMode: await prefs.darkMode(),
    shareBleed: await prefs.shareBleed(),
    shareFertile: await prefs.shareFertile(),
    shareSymptoms: await prefs.shareSymptoms(),
  );

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

  void setShareBleed(bool v) {
    shareBleed = v;
    notifyListeners();
    _prefs.setShareBleed(v);
  }

  void setShareFertile(bool v) {
    shareFertile = v;
    notifyListeners();
    _prefs.setShareFertile(v);
  }

  void setShareSymptoms(bool v) {
    shareSymptoms = v;
    notifyListeners();
    _prefs.setShareSymptoms(v);
  }
}
