import 'package:flutter/material.dart';

import '../models/cycle_settings.dart';
import '../models/tracking_mode.dart';
import '../services/cycle_calculator.dart';
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

  /// Minimum spacing between period start dates (guards typos / same-cycle double logs).
  static const int minGapDays = 15;

  /// Cap on earlier-period rows so the onboarding list stays scannable.
  static const int maxPreviousPeriods = 6;

  static const int minCycleLength = 20;
  static const int maxCycleLength = 40;

  /// Reason the most recent add/replace attempt failed, for the UI to show.
  String? lastValidationError;

  final PrefsService _prefs;
  bool onboarded;
  int selectedDay;
  int cycleLength;
  int bleedLength;
  Set<TrackingMode> trackingModes;
  int? yearOfBirth;
  DateTime lastPeriodStart;
  DateTime? pickedDate;

  /// True while [cycleLength] was last set from the entered history (not the slider).
  bool cycleLengthFromHistory = false;

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

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Gap in days between [a] and [b], always positive.
  static int _gap(DateTime a, DateTime b) => CycleCalculator.daysBetween(a, b).abs();

  /// Reason [d] cannot be added as an earlier period start, or null when valid.
  /// Checks duplicates, the 15-day minimum gap, and list capacity.
  /// Pass [ignoring] to exclude a row being edited in place.
  String? validatePreviousPeriod(DateTime d, {DateTime? ignoring}) {
    final day = _day(d);
    if (previousPeriodStarts.any((e) => e == day && e != ignoring)) return 'This date is already listed.';
    // Always checked, even when editing: the picked last period is never a list row.
    if (pickedDate != null && _gap(day, pickedDate!) < minGapDays) {
      return 'Too close to your last period - keep at least $minGapDays days between starts.';
    }
    for (final existing in previousPeriodStarts) {
      if (ignoring != null && existing == ignoring) continue;
      if (_gap(day, existing) < minGapDays) {
        return 'Too close to another period - keep at least $minGapDays days between starts.';
      }
    }
    if (ignoring == null && previousPeriodStarts.length >= maxPreviousPeriods) {
      return 'Remove an older date first - up to $maxPreviousPeriods earlier periods.';
    }
    return null;
  }

  /// Records an earlier period start; returns false when [validatePreviousPeriod] fails.
  /// The failing reason is stored in [lastValidationError].
  bool addPreviousPeriod(DateTime d) {
    final error = validatePreviousPeriod(d);
    lastValidationError = error;
    if (error != null) return false;
    previousPeriodStarts.add(_day(d));
    previousPeriodStarts.sort((a, b) => b.compareTo(a));
    notifyListeners();
    return true;
  }

  /// Replaces [old] with [newDate] after re-validating the new date against the rest.
  bool replacePreviousPeriod(DateTime old, DateTime newDate) {
    final oldDay = _day(old);
    if (_day(newDate) == oldDay) return true;
    final error = validatePreviousPeriod(newDate, ignoring: oldDay);
    lastValidationError = error;
    if (error != null) return false;
    previousPeriodStarts.removeWhere((e) => e == oldDay);
    previousPeriodStarts.add(_day(newDate));
    previousPeriodStarts.sort((a, b) => b.compareTo(a));
    notifyListeners();
    return true;
  }

  void removePreviousPeriod(DateTime d) {
    final day = _day(d);
    previousPeriodStarts.removeWhere((e) => e == day);
    notifyListeners();
  }

  /// Median cycle length implied by the entered dates, clamped to the slider range;
  /// null until 2+ complete cycles are known.
  int? deriveCycleLengthFromHistory() {
    final starts = [...previousPeriodStarts, if (pickedDate != null) pickedDate!]..sort();
    if (starts.length < 2) return null;
    final median = PeriodHistory.median(PeriodHistory.cycleLengths(starts));
    if (median == null) return null;
    return median.clamp(minCycleLength, maxCycleLength);
  }

  void setCycle(int v, {bool fromHistory = false}) {
    cycleLength = v.clamp(minCycleLength, maxCycleLength);
    cycleLengthFromHistory = fromHistory;
    notifyListeners();
  }

  void setBleed(int v) {
    bleedLength = v.clamp(2, 10);
    notifyListeners();
  }

  /// Persists the current rhythm values without touching onboarding state;
  /// used when the cycle/bleed lengths are edited after onboarding.
  Future<void> persistRhythms() => _prefs.saveRhythms(cycleLength, bleedLength, lastPeriodStart);

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
    cycleLengthFromHistory = false;
    lastValidationError = null;
    previousPeriodStarts.clear();
    notifyListeners();
  }
}
