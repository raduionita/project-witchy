import 'package:flutter/material.dart';

import '../models/cycle_settings.dart';
import '../models/tracking_mode.dart';
import '../services/prefs_service.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(
    this._prefs, {
    this.onboarded = false,
    this.selectedDay = 17,
    this.cycleLength = 28,
    this.bleedLength = 5,
    Set<TrackingMode>? trackingModes,
    int? yearOfBirth,
    DateTime? lastPeriodStart,
  }) : trackingModes = (trackingModes == null || trackingModes.isEmpty) ? {TrackingMode.cycle} : {...trackingModes},
       yearOfBirth = yearOfBirth ?? DateTime.now().year - 25,
       lastPeriodStart = lastPeriodStart ?? _derive(selectedDay);

  final PrefsService _prefs;
  bool onboarded;
  int selectedDay;
  int cycleLength;
  int bleedLength;
  Set<TrackingMode> trackingModes;
  int? yearOfBirth;
  DateTime lastPeriodStart;
  DateTime? pickedDate;

  static DateTime _derive(int day) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, day <= 28 ? day : 28);
  }

  CycleSettings get cycleSettings => CycleSettings(lastPeriodStart: lastPeriodStart, cycleLength: cycleLength, bleedLength: bleedLength);

  static Future<OnboardingProvider> load(PrefsService prefs) async {
    final last = await prefs.lastPeriod();
    final selected = last?.day ?? 17;
    return OnboardingProvider(
      prefs,
      onboarded: await prefs.isOnboarded(),
      cycleLength: await prefs.cycleLength(),
      bleedLength: await prefs.bleedLength(),
      trackingModes: await prefs.trackingModes(),
      yearOfBirth: await prefs.birthYear(),
      selectedDay: selected,
      lastPeriodStart: last ?? _derive(selected),
    );
  }

  /// Multi-toggle: adds/removes [mode] but always keeps at least one active.
  void toggleTrackingMode(TrackingMode mode) {
    final next = {...trackingModes};
    if (next.contains(mode)) {
      if (next.length == 1) return;
      next.remove(mode);
    } else {
      next.add(mode);
    }
    trackingModes = next;
    notifyListeners();
    _prefs.setTrackingModes(next);
  }

  void setYear(int y) {
    yearOfBirth = y;
    notifyListeners();
  }

  void setDay(int d) {
    selectedDay = d;
    notifyListeners();
  }

  void setDate(DateTime d) {
    pickedDate = DateTime(d.year, d.month, d.day);
    selectedDay = pickedDate!.day;
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
    final last = pickedDate ?? DateTime(now.year, now.month, selectedDay <= 28 ? selectedDay : 28);
    lastPeriodStart = last;
    await _prefs.saveRhythms(cycleLength, bleedLength, last);
    await _prefs.setTrackingModes(trackingModes);
    final year = yearOfBirth;
    if (year != null) await _prefs.setBirthYear(year);
    await _prefs.setOnboarded();
    onboarded = true;
    notifyListeners();
  }

  /// In-memory reset after Delete All Data (prefs already wiped).
  void resetToDefaults() {
    onboarded = false;
    selectedDay = 17;
    cycleLength = 28;
    bleedLength = 5;
    trackingModes = {TrackingMode.cycle};
    yearOfBirth = DateTime.now().year - 25;
    lastPeriodStart = _derive(17);
    pickedDate = null;
    notifyListeners();
  }
}
