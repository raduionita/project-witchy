import '../models/day_log.dart';
import '../models/period_span.dart';
import 'cycle_calculator.dart';

class PeriodHistory {
  PeriodHistory._();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isBleedDay(DayLog? log) => log != null && log.flow != 'None';

  /// Groups logged bleed days into consecutive spans, oldest first.
  static List<PeriodSpan> spans(Map<DateTime, DayLog> logs) {
    final dates = logs.entries.where((e) => isBleedDay(e.value)).map((e) => _day(e.key)).toList()..sort();
    final result = <PeriodSpan>[];
    for (final date in dates) {
      if (result.isNotEmpty && CycleCalculator.daysBetween(result.last.end, date) == 1) {
        result[result.length - 1] = PeriodSpan(start: result.last.start, end: date);
      } else {
        result.add(PeriodSpan(start: date, end: date));
      }
    }
    return result;
  }

  static List<DateTime> startsOf(List<PeriodSpan> spans) => [for (final s in spans) s.start];

  /// Completed cycle lengths between consecutive period starts.
  static List<int> cycleLengths(List<DateTime> starts) => [
    for (var i = 1; i < starts.length; i++) CycleCalculator.daysBetween(starts[i - 1], starts[i]),
  ];

  static int? median(List<int> values) {
    if (values.isEmpty) return null;
    final sorted = [...values]..sort();
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd ? sorted[mid] : ((sorted[mid - 1] + sorted[mid]) / 2).round();
  }

  static double? mean(Iterable<num> values) {
    if (values.isEmpty) return null;
    var total = 0.0;
    for (final v in values) {
      total += v;
    }
    return total / values.length;
  }
}
