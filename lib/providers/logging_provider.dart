import 'package:flutter/material.dart';

import '../models/day_log.dart';
import '../services/prefs_service.dart';

class LoggingProvider extends ChangeNotifier {
  LoggingProvider(this._prefs, {Map<String, DayLog>? days}) : _days = days ?? {};

  final PrefsService _prefs;
  final Map<String, DayLog> _days;

  static Future<LoggingProvider> load(PrefsService prefs) async => LoggingProvider(prefs, days: await prefs.loadDayLogs());

  static String keyFor(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DayLog day(DateTime d) => _days.putIfAbsent(keyFor(d), () => DayLog());

  void setFlow(DateTime d, String v) {
    day(d).flow = v;
    notifyListeners();
    _save();
  }

  void toggleMood(DateTime d, String v) {
    final m = day(d).moods;
    m.contains(v) ? m.remove(v) : m.add(v);
    notifyListeners();
    _save();
  }

  void toggleSymptom(DateTime d, String v) {
    final s = day(d).symptoms;
    s.contains(v) ? s.remove(v) : s.add(v);
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
