import 'package:flutter/material.dart';

import '../services/prefs_service.dart';

/// Reads and computes gestational age from the last menstrual period (LMP).
class GestationProvider extends ChangeNotifier {
  GestationProvider(this._prefs, {DateTime? lmpDate}) : lmpDate = _day(lmpDate);

  static const gestationDays = 280;

  final PrefsService _prefs;
  DateTime? lmpDate;

  static DateTime? _day(DateTime? d) => d == null ? null : DateTime(d.year, d.month, d.day);

  static Future<GestationProvider> load(PrefsService prefs) async => GestationProvider(prefs, lmpDate: await prefs.lmpDate());

  bool get hasLmp => lmpDate != null;

  Future<void> setLmp(DateTime date) async {
    lmpDate = _day(date);
    notifyListeners();
    await _prefs.setLmpDate(lmpDate!);
  }

  int days({DateTime? today}) {
    final lmp = lmpDate;
    if (lmp == null) return 0;
    final t = _day(today) ?? DateTime.now();
    final diff = t.difference(lmp).inDays;
    return diff < 0 ? 0 : diff;
  }

  int week({DateTime? today}) => days(today: today) ~/ 7;

  int dayOfWeek({DateTime? today}) => days(today: today) % 7;

  double progress({DateTime? today}) => (days(today: today) / gestationDays).clamp(0.0, 1.0);

  int daysRemaining({DateTime? today}) {
    final left = gestationDays - days(today: today);
    return left < 0 ? 0 : left;
  }

  int daysPastDue({DateTime? today}) {
    final over = days(today: today) - gestationDays;
    return over > 0 ? over : 0;
  }

  DateTime? get dueDate => lmpDate?.add(const Duration(days: gestationDays));

  int trimester({DateTime? today}) {
    final w = week(today: today);
    if (w < 13) return 1;
    if (w < 28) return 2;
    return 3;
  }

  /// In-memory reset after Delete All Data (prefs already wiped).
  void resetToDefaults() {
    lmpDate = null;
    notifyListeners();
  }
}
