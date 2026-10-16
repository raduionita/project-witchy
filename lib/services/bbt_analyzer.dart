import 'cycle_calculator.dart';
import 'period_history.dart';

/// Biphasic-shift detection over logged basal body temperatures.
///
/// Local heuristic, not a diagnosis: a sustained post-ovulatory rise of at
/// least [riseThresholdC] over the preceding 6-day baseline marks ovulation on
/// the day before the rise. Temperatures are °C (the log sheet records
/// 35.0-38.0 °C), so no unit conversion happens here.
class BbtAnalyzer {
  BbtAnalyzer._();

  /// Minimum usable readings before any output is produced.
  static const int minReadings = 10;

  /// Minimum readings inside the 6-day pre-rise baseline.
  static const int minBaselineReadings = 4;

  /// Minimum readings inside the 3-day post-rise window.
  static const int minPostRiseReadings = 2;

  /// Sustained rise over the baseline that counts as a biphasic shift (°C).
  static const double riseThresholdC = 0.3;

  /// Arithmetic fallback when no personal luteal length is measurable.
  static const int fallbackLutealLength = 14;

  /// Sanity bounds for a measured luteal length.
  static const int minLutealLength = 10;
  static const int maxLutealLength = 18;

  /// Detects the most recent BBT-confirmed ovulation and the personal luteal
  /// length (median ovulation-to-next-bleed gap, clamped). Either output is
  /// null when the logged temperatures cannot support it.
  static ({DateTime? confirmedOvulation, int? personalLutealLength}) analyze({
    required Map<DateTime, double?> temps,
    required List<DateTime> bleedStarts,
    DateTime? today,
  }) {
    final now = _day(today ?? DateTime.now());
    final readings = <DateTime, double>{};
    for (final entry in temps.entries) {
      final value = entry.value;
      if (value == null) continue;
      readings[_day(entry.key)] = value;
    }
    if (readings.length < minReadings) {
      return (confirmedOvulation: null, personalLutealLength: null);
    }

    final ovulations = _detectShifts(readings, now);
    DateTime? confirmed;
    final past = [for (final o in ovulations) if (!o.isAfter(now)) o];
    if (past.isNotEmpty) confirmed = past.last;

    final starts = [for (final s in bleedStarts) _day(s)]..sort();
    final luteals = <int>[];
    for (final ovu in ovulations) {
      DateTime? next;
      for (final s in starts) {
        if (s.isAfter(ovu)) {
          next = s;
          break;
        }
      }
      if (next != null) luteals.add(CycleCalculator.daysBetween(ovu, next));
    }
    int? personal;
    final median = PeriodHistory.median(luteals);
    if (median != null) personal = median.clamp(minLutealLength, maxLutealLength);

    return (confirmedOvulation: confirmed, personalLutealLength: personal);
  }

  /// Every ovulation date implied by a sustained rise, oldest first. A rise on
  /// [d] means ovulation around [d] minus one day; candidates within 6 days of
  /// an accepted shift are skipped so one rise is never counted twice.
  static List<DateTime> _detectShifts(Map<DateTime, double> readings, DateTime now) {
    final found = <DateTime>[];
    final keys = readings.keys.toList()..sort();
    var day = _addDays(keys.first, 6);
    while (!day.isAfter(now)) {
      if (found.any((o) => day.difference(o).inDays.abs() < 6)) {
        day = _addDays(day, 1);
        continue;
      }
      final baseline = <double>[];
      for (var i = 6; i >= 1; i--) {
        final value = readings[_addDays(day, -i)];
        if (value != null) baseline.add(value);
      }
      final post = <double>[];
      for (var i = 0; i <= 2; i++) {
        final value = readings[_addDays(day, i)];
        if (value != null) post.add(value);
      }
      if (baseline.length >= minBaselineReadings && post.length >= minPostRiseReadings) {
        final mean = baseline.reduce((a, b) => a + b) / baseline.length;
        final postMean = post.reduce((a, b) => a + b) / post.length;
        if (postMean - mean >= riseThresholdC && post.every((t) => t > mean)) {
          found.add(_addDays(day, -1));
        }
      }
      day = _addDays(day, 1);
    }
    return found;
  }

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);
}
