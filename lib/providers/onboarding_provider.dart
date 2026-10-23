import 'package:flutter/material.dart';

import '../models/cycle_condition.dart';
import '../models/cycle_settings.dart';
import '../models/period_range.dart';
import '../models/tracking_mode.dart';
import '../services/period_history.dart';
import '../services/period_range_rules.dart';
import '../services/prefs_service.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider(
    this._prefs, {
    this.onboarded = false,
    this.selectedDay = 17,
    this.cycleLength = 28,
    this.bleedLength = 5,
    Set<TrackingMode>? trackingModes,
    Set<CycleCondition>? cycleConditions,
    int? yearOfBirth,
    DateTime? lastPeriodStart,
  }) : trackingModes = (trackingModes == null || trackingModes.isEmpty) ? {TrackingMode.cycle} : {...trackingModes},
       cycleConditions = {...?cycleConditions},
       yearOfBirth = yearOfBirth ?? DateTime.now().year - 25,
       _fallbackLastPeriodStart = lastPeriodStart ?? _derive(selectedDay);

  /// How many periods can be listed during onboarding.
  static const int maxPeriods = PeriodRangeRules.maxRanges;

  static const int minCycleLength = 15;
  static const int maxCycleLength = 60;

  /// Reason the most recent add/replace attempt failed, for the UI to show.
  String? lastValidationError;

  final PrefsService _prefs;
  bool onboarded;
  int selectedDay;
  int cycleLength;
  int bleedLength;
  Set<TrackingMode> trackingModes;
  Set<CycleCondition> cycleConditions;
  int? yearOfBirth;

  /// Anchor used when the user never added a period; keeps the saved rhythm
  /// of returning users.
  DateTime _fallbackLastPeriodStart;

  /// True while [cycleLength] was last set from the entered history (not the slider).
  bool cycleLengthFromHistory = false;

  /// The periods the user added during onboarding, newest first. The newest
  /// start is the anchor for every prediction.
  final List<PeriodRange> pastPeriods = [];

  /// The picked periods, newest first.
  List<PeriodRange> get periodRanges => List.unmodifiable(pastPeriods);

  /// First day of the most recent period, or null when none was added.
  DateTime? get pickedDate => pastPeriods.isEmpty ? null : pastPeriods.first.start;

  /// The anchor every prediction starts from: the newest period start.
  DateTime get lastPeriodStart =>
      pastPeriods.isEmpty ? _fallbackLastPeriodStart : pastPeriods.first.start;

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
      cycleConditions: await prefs.cycleConditions(),
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

  void toggleCycleCondition(CycleCondition condition) {
    final next = {...cycleConditions};
    if (!next.remove(condition)) next.add(condition);
    cycleConditions = next;
    notifyListeners();
    _prefs.setCycleConditions(next);
  }

  void setYear(int y) {
    yearOfBirth = y;
    notifyListeners();
  }

  void setDay(int d) {
    selectedDay = d;
    notifyListeners();
  }

  /// Adds a period range after checking the shared rules. Returns false when
  /// the range is rejected; the reason lands in [lastValidationError].
  bool addPeriodRange(PeriodRange range) {
    final error = PeriodRangeRules.validate(range: range, existing: pastPeriods);
    lastValidationError = error;
    if (error != null) return false;
    pastPeriods.add(range);
    _sortPeriods();
    notifyListeners();
    return true;
  }

  /// Replaces the range that started on [originalStart] with [range], after
  /// re-checking it against the other periods.
  bool replacePeriodRange(DateTime originalStart, PeriodRange range) {
    final others = pastPeriods.where((r) => r.start != originalStart).toList();
    final error = PeriodRangeRules.validate(
      range: range,
      existing: others,
      editing: PeriodRange(start: originalStart, end: originalStart),
    );
    lastValidationError = error;
    if (error != null) return false;
    pastPeriods.removeWhere((r) => r.start == originalStart);
    pastPeriods.add(range);
    _sortPeriods();
    notifyListeners();
    return true;
  }

  /// Removes the period that started on [start].
  void removePeriodRange(DateTime start) {
    pastPeriods.removeWhere((r) => r.start == start);
    notifyListeners();
  }

  /// Puts back a period that was removed by mistake (the undo action). It skips
  /// the rules because the range was accepted a moment ago.
  void restorePeriodRange(PeriodRange range) {
    if (pastPeriods.any((r) => r.start == range.start)) return;
    pastPeriods.add(range);
    _sortPeriods();
    lastValidationError = null;
    notifyListeners();
  }

  /// Newest first, so the most recent period always anchors the predictions.
  void _sortPeriods() => pastPeriods.sort((a, b) => b.start.compareTo(a.start));

  /// Median cycle length implied by the entered dates, clamped to the slider range;
  /// null until 2+ complete cycles are known.
  int? deriveCycleLengthFromHistory() {
    final starts = pastPeriods.map((range) => range.start).toList()..sort();
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
    _fallbackLastPeriodStart = last;
    await _prefs.saveRhythms(cycleLength, bleedLength, last);
    await _prefs.setTrackingModes(trackingModes);
    await _prefs.setCycleConditions(cycleConditions);
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
    cycleConditions = {};
    yearOfBirth = DateTime.now().year - 25;
    _fallbackLastPeriodStart = _derive(17);
    cycleLengthFromHistory = false;
    lastValidationError = null;
    pastPeriods.clear();
    notifyListeners();
  }
}
