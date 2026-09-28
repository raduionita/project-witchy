import 'package:flutter/material.dart';

import '../services/prefs_service.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(this._prefs, {this.onboarded = false, this.selectedDay = 17, this.cycleLength = 28, this.bleedLength = 5});

  final PrefsService _prefs;
  bool onboarded;
  int selectedDay;
  int cycleLength;
  int bleedLength;

  static Future<OnboardingProvider> load(PrefsService prefs) async {
    final last = await prefs.lastPeriod();
    return OnboardingProvider(
      prefs,
      onboarded: await prefs.isOnboarded(),
      cycleLength: await prefs.cycleLength(),
      bleedLength: await prefs.bleedLength(),
      selectedDay: last?.day ?? 17,
    );
  }

  void setDay(int d) {
    selectedDay = d;
    notifyListeners();
  }

  void setCycle(int v) {
    cycleLength = v;
    notifyListeners();
  }

  void setBleed(int v) {
    bleedLength = v;
    notifyListeners();
  }

  Future<void> finish() async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, selectedDay <= 28 ? selectedDay : 28);
    await _prefs.saveRhythms(cycleLength, bleedLength, last);
    await _prefs.setOnboarded();
    onboarded = true;
    notifyListeners();
  }
}
