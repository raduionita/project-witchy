import 'package:flutter/material.dart';

import '../models/day_log.dart';
import '../models/period_record.dart';
import '../services/period_history.dart';
import '../services/prefs_service.dart';

class LoggingProvider extends ChangeNotifier {
  LoggingProvider(
    this._prefs, {
    Map<String, DayLog>? days,
    List<PeriodRecord>? records,
  }) : _days = days ?? {},
       _records = records ?? [];

  final PrefsService _prefs;
  final Map<String, DayLog> _days;
  final List<PeriodRecord> _records;

  static Future<LoggingProvider> load(PrefsService prefs) async {
    final days = await prefs.loadDayLogs();
    final records = await prefs.loadPeriodRecords();
    await _migrateAssumed(prefs, days, records);
    return LoggingProvider(prefs, days: days, records: records);
  }

  /// Converts old onboarding-seeded flow days into explicit estimated period
  /// records, preserving any notes or symptoms logged on those days.
  static Future<void> _migrateAssumed(
    PrefsService prefs,
    Map<String, DayLog> days,
    List<PeriodRecord> records,
  ) async {
    final assumed = <DateTime, DayLog>{
      for (final entry in days.entries)
        if (entry.value.assumed) DateTime.parse(entry.key): entry.value,
    };
    final knownStarts = {for (final record in records) keyFor(record.start)};
    var changed = false;
    for (final span in PeriodHistory.spans(assumed)) {
      final startKey = keyFor(span.start);
      if (!knownStarts.contains(startKey)) {
        records.add(
          PeriodRecord(
            start: span.start,
            end: span.end,
            source: PeriodSource.migrated,
            estimated: true,
          ),
        );
        knownStarts.add(startKey);
      }
      for (var day = span.start; !day.isAfter(span.end); day = DateTime(day.year, day.month, day.day + 1)) {
        final key = keyFor(day);
        final entry = days[key];
        if (entry == null) continue;
        entry.flow.clear();
        entry.assumed = false;
        if (!entry.hasDetails) days.remove(key);
        changed = true;
      }
    }
    final last = await prefs.lastPeriod();
    if (last != null && !knownStarts.contains(keyFor(last))) {
      records.add(
        PeriodRecord(
          start: DateTime(last.year, last.month, last.day),
          source: PeriodSource.migrated,
          estimated: true,
        ),
      );
      changed = true;
    }
    if (changed) {
      _sortRecords(records);
      await prefs.saveDayLogs(days);
      await prefs.savePeriodRecords(records);
    }
  }

  static String keyFor(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Create-or-update entry used only by mutators — views must use [peekDay].
  DayLog day(DateTime d) => _days.putIfAbsent(keyFor(d), () => DayLog());

  /// Read-only lookup: never materializes an entry for an unlogged day.
  DayLog? peekDay(DateTime d) => _days[keyFor(d)];

  bool hasLog(DateTime d) => _days.containsKey(keyFor(d));

  Map<DateTime, DayLog> snapshot() => {for (final e in _days.entries) DateTime.parse(e.key): e.value};

  List<PeriodRecord> get periodRecords => List.unmodifiable(_records);

  void addPeriodRecord(
    DateTime start, {
    DateTime? end,
    PeriodSource source = PeriodSource.manual,
    bool estimated = false,
  }) {
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = end == null ? null : DateTime(end.year, end.month, end.day);
    _records.removeWhere((record) => keyFor(record.start) == keyFor(dayStart));
    _records.add(
      PeriodRecord(
        start: dayStart,
        end: dayEnd,
        source: source,
        estimated: estimated,
      ),
    );
    _sortRecords(_records);
    notifyListeners();
    _saveRecords();
  }

  void updatePeriodRecord(
    DateTime originalStart, {
    required DateTime start,
    DateTime? end,
    PeriodSource source = PeriodSource.manual,
    bool estimated = false,
  }) {
    final originalKey = keyFor(originalStart);
    _records.removeWhere((record) => keyFor(record.start) == originalKey);
    addPeriodRecord(start, end: end, source: source, estimated: estimated);
  }

  void deletePeriodRecord(DateTime start) {
    final key = keyFor(start);
    final before = _records.length;
    _records.removeWhere((record) => keyFor(record.start) == key);
    if (_records.length == before) return;
    notifyListeners();
    _saveRecords();
  }

  void replaceOnboardingRecords(Iterable<PeriodRecord> records) {
    _records.removeWhere(
      (record) =>
          record.source == PeriodSource.onboarding ||
          record.source == PeriodSource.migrated,
    );
    _records.addAll(records);
    _sortRecords(_records);
    notifyListeners();
    _saveRecords();
  }

  static void _sortRecords(List<PeriodRecord> records) =>
      records.sort((a, b) => a.start.compareTo(b.start));

  void deleteDay(DateTime d) {
    if (_days.remove(keyFor(d)) != null) {
      notifyListeners();
      _save();
    }
  }

  /// Restore an [original] snapshot, or remove the entry when it was null
  /// (no log existed when editing started) — used by sheet cancel.
  void restoreDay(DateTime d, DayLog? original) {
    original == null ? _days.remove(keyFor(d)) : _days[keyFor(d)] = original;
    notifyListeners();
    _save();
  }

  /// Replace-style flow set: single-select screens (blood volume, onboarding seed).
  /// Writing flow by hand clears the [DayLog.assumed] flag: the day is the
  /// user's own record from here on.
  void setFlow(DateTime d, String v) {
    final entry = day(d);
    entry.flow
      ..clear()
      ..add(v);
    entry.assumed = false;
    notifyListeners();
    _save();
  }

  /// Seeds an onboarding-history span: every day is stored with [DayLog.assumed]
  /// so history can label it 'Estimated' instead of pretending it was logged.
  void seedAssumedSpan(DateTime start, int days, String flow) {
    if (days < 1) return;
    for (var i = 0; i < days; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      final entry = day(date);
      entry.flow
        ..clear()
        ..add(flow);
      entry.assumed = true;
    }
    notifyListeners();
    _save();
  }

  /// Removes every assumed (onboarding-seeded) day and returns how many went.
  /// Called before re-seeding so an earlier run can never leave a phantom
  /// period behind.
  int wipeAssumed() {
    final keys = [for (final e in _days.entries) if (e.value.assumed) e.key];
    for (final key in keys) {
      _days.remove(key);
    }
    if (keys.isNotEmpty) {
      notifyListeners();
      _save();
    }
    return keys.length;
  }

  /// Log-sheet flow: one level at a time. Tapping the active level clears it.
  /// Clearing the last level also drops the collection method(s): a method is
  /// only meaningful while there is bleeding to collect.
  void selectFlow(DateTime d, String v) {
    final entry = day(d);
    final flow = entry.flow;
    final onlyThis = flow.length == 1 && flow.contains(v);
    flow.clear();
    if (!onlyThis) flow.add(v);
    if (flow.isEmpty) entry.collection.clear();
    notifyListeners();
    _save();
  }

  void toggleMood(DateTime d, String v) => _toggle(day(d).moods, v);

  void toggleSymptom(DateTime d, String v) => _toggle(day(d).symptoms, v);

  void toggleCollection(DateTime d, String v) => _toggle(day(d).collection, v);

  void toggleDigestion(DateTime d, String v) => _toggle(day(d).digestion, v);

  void toggleSkinHair(DateTime d, String v) => _toggle(day(d).skinHair, v);

  void toggleCravings(DateTime d, String v) => _toggle(day(d).cravings, v);

  void toggleSex(DateTime d, String v) => _toggle(day(d).sex, v);

  void toggleSleep(DateTime d, String v) => _toggle(day(d).sleep, v);

  void toggleDischarge(DateTime d, String v) => _toggle(day(d).discharge, v);

  void _toggle(Set<String> set, String v) {
    set.contains(v) ? set.remove(v) : set.add(v);
    notifyListeners();
    _save();
  }

  void setPain(DateTime d, double v) {
    day(d).pain = v;
    notifyListeners();
    _save();
  }

  void setTemperature(DateTime d, double? v) {
    day(d).temperature = v;
    notifyListeners();
    _save();
  }

  /// Ovulation test result: 'positive' / 'negative' / null (cleared).
  void setOvulationTest(DateTime d, String? v) {
    day(d).ovulationTest = v;
    notifyListeners();
    _save();
  }

  void setNotes(DateTime d, String v) {
    day(d).notes = v;
    notifyListeners();
    _save();
  }

  void _save() => _prefs.saveDayLogs(_days);

  void _saveRecords() => _prefs.savePeriodRecords(_records);

  /// In-memory reset after Delete All Data (prefs already wiped).
  void resetToDefaults() {
    _days.clear();
    _records.clear();
    notifyListeners();
  }
}
