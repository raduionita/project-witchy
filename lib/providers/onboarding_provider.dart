import 'package:flutter/material.dart';

import '../models/cycle_settings.dart';
import '../models/tracking_mode.dart';
import '../services/period_history.dart';
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

  /// Start dates of earlier periods entered during onboarding, newest first.
  /// Persisted indirectly: `rhythms_screen` seeds them into the day-log store,
  /// so `PeriodHistory` derives real cycle lengths from them.
  final List<DateTime> previousPeriodStarts = [];

  /// Fallback anchor when the user never picked a date. Never lands in the
  /// future - a future "last period" date poisons every cycle calculation.
  static DateTime _derive(int day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final candidate = DateTime(now.year, now.month, day <= 28 ? day : 28);
    return candidate.isAfter(today) ? today : candidate;
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

  /// Records an earlier period start; duplicates are ignored and order stays newest-first.
  void addPreviousPeriod(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    if (previousPeriodStarts.contains(day)) return;
    previousPeriodStarts.add(day);
    previousPeriodStarts.sort((a, b) => b.compareTo(a));
    notifyListeners();
  }

  void removePreviousPeriod(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    previousPeriodStarts.removeWhere((e) => e == day);
    notifyListeners();
  }

  /// Median cycle length implied by the entered dates; null until 2+ complete cycles are known.
  int? deriveCycleLengthFromHistory() {
    final starts = [...previousPeriodStarts, if (pickedDate != null) pickedDate!]..sort();
    if (starts.length < 2) return null;
    return PeriodHistory.median(PeriodHistory.cycleLengths(starts));
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
    final last = pickedDate ?? _derive(selectedDay);
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
    previousPeriodStarts.clear();
    notifyListeners();
  }
}
