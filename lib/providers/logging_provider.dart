import 'package:flutter/material.dart';

import '../models/day_log.dart';
import '../services/prefs_service.dart';

class LoggingProvider extends ChangeNotifier {
  LoggingProvider(this._prefs, {Map<String, DayLog>? days}) : _days = days ?? {};

  final PrefsService _prefs;
  final Map<String, DayLog> _days;

  static Future<LoggingProvider> load(PrefsService prefs) async => LoggingProvider(prefs, days: await prefs.loadDayLogs());

  static String keyFor(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// Create-or-update entry used only by mutators — views must use [peekDay].
  DayLog day(DateTime d) => _days.putIfAbsent(keyFor(d), () => DayLog());

  /// Read-only lookup: never materializes an entry for an unlogged day.
  DayLog? peekDay(DateTime d) => _days[keyFor(d)];

  bool hasLog(DateTime d) => _days.containsKey(keyFor(d));

  Map<DateTime, DayLog> snapshot() => {for (final e in _days.entries) DateTime.parse(e.key): e.value};

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
  void setFlow(DateTime d, String v) {
    day(d).flow..clear()..add(v);
    notifyListeners();
    _save();
  }

  void toggleFlow(DateTime d, String v) => _toggle(day(d).flow, v);

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

  void setNotes(DateTime d, String v) {
    day(d).notes = v;
    notifyListeners();
    _save();
  }

  void _save() => _prefs.saveDayLogs(_days);
}
