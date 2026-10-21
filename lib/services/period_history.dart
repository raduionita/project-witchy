import '../models/day_log.dart';
import '../models/period_record.dart';
import '../models/period_span.dart';
import 'cycle_calculator.dart';

class PeriodHistory {
  PeriodHistory._();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isBleedDay(DayLog? log) => log != null && log.flow.isNotEmpty;

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

  /// Merges explicit period starts with real flow spans. A logged flow span
  /// always wins over an estimated record that overlaps it, so editing flow
  /// never leaves a duplicate period behind.
  static List<PeriodSpan> spansFrom(
    Map<DateTime, DayLog> logs,
    Iterable<PeriodRecord> records,
  ) {
    final real = spans(logs);
    final byStart = <DateTime, PeriodSpan>{};
    for (final record in records) {
      final start = _day(record.start);
      final end = _day(record.end ?? record.start);
      final overlapsReal = real.any(
        (span) => !start.isAfter(span.end) && !end.isBefore(span.start),
      );
      if (overlapsReal) continue;
      byStart[start] = PeriodSpan(
        start: start,
        end: end,
        estimated: record.estimated,
        startOnly: record.startOnly,
      );
    }
    for (final span in real) {
      byStart[_day(span.start)] = span;
    }
    return byStart.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Starts of real periods only: spans shorter than [minSpanDays] are spotting
  /// and never seed cycle math, BBT baselines or OPK luteal estimates.
  static const int minSpanDays = 2;

  /// Spans that qualify as periods: a known start, even without an end, or at
  /// least [minSpanDays] consecutive logged days.
  static List<PeriodSpan> periods(List<PeriodSpan> spans) =>
      [for (final s in spans) if (s.startOnly || s.length >= minSpanDays) s];

  /// Isolated short spans, surfaced as spotting rather than as periods.
  static List<PeriodSpan> spotting(List<PeriodSpan> spans) =>
      [for (final s in spans) if (!s.startOnly && s.length < minSpanDays) s];

  static List<DateTime> startsOf(List<PeriodSpan> spans) => [for (final s in periods(spans)) s.start];

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
