import 'package:flutter/material.dart';

import '../services/prefs_service.dart';

/// Reads and computes gestational age from the last menstrual period (LMP).
class GestationProvider extends ChangeNotifier {
  GestationProvider(this._prefs, {DateTime? lmpDate, DateTime? eddOverride})
      : lmpDate = _day(lmpDate),
        eddOverride = _day(eddOverride);

  static const gestationDays = 280;

  final PrefsService _prefs;
  DateTime? lmpDate;

  /// Doctor-set due date; null means LMP-based dating. Day-normalized.
  DateTime? eddOverride;

  static DateTime? _day(DateTime? d) => d == null ? null : DateTime(d.year, d.month, d.day);

  static Future<GestationProvider> load(PrefsService prefs) async =>
      GestationProvider(prefs, lmpDate: await prefs.lmpDate(), eddOverride: await prefs.eddOverride());

  bool get hasLmp => lmpDate != null;

  Future<void> setLmp(DateTime date) async {
    lmpDate = _day(date);
    notifyListeners();
    await _prefs.setLmpDate(lmpDate!);
  }

  /// Null clears the override and restores LMP-based dating.
  Future<void> setEddOverride(DateTime? date) async {
    eddOverride = _day(date);
    notifyListeners();
    await _prefs.setEddOverride(eddOverride);
  }

  int days({DateTime? today}) {
    final t = _day(today) ?? _day(DateTime.now())!;
    final override = eddOverride;
    // A doctor-set due date re-anchors gestational age: 280 minus the
    // remaining days. Otherwise age counts up from the LMP.
    if (override != null) {
      final diff = gestationDays - override.difference(t).inDays;
      return diff < 0 ? 0 : diff;
    }
    final lmp = lmpDate;
    if (lmp == null) return 0;
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

  DateTime? get dueDateNaegele => lmpDate?.add(const Duration(days: gestationDays));

  /// Parikh alternative for non-28-day cycles: Naegele shifted by (cycle - 28).
  DateTime? dueDateParikh(int cycleLength) => lmpDate?.add(Duration(days: gestationDays + (cycleLength - 28)));

  /// Effective due date: doctor override wins, otherwise Naegele from the LMP.
  DateTime? get dueDate => eddOverride ?? dueDateNaegele;

  /// Provenance label for the effective due date.
  String get dueDateSource => eddOverride != null ? 'doctor' : 'LMP';

  int trimester({DateTime? today}) {
    final w = week(today: today);
    if (w < 13) return 1;
    if (w < 28) return 2;
    return 3;
  }

  /// In-memory reset after Delete All Data (prefs already wiped).
  void resetToDefaults() {
    lmpDate = null;
    eddOverride = null;
    notifyListeners();
  }
}
