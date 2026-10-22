import '../models/day_log.dart';
import '../models/period_record.dart';
import '../models/period_span.dart';
import 'cycle_calculator.dart';

class PeriodHistory {
  PeriodHistory._();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool isBleedDay(DayLog? log) => log != null && log.flow.isNotEmpty;

  static const String spottingFlow = 'Spotting';

  /// True when the day has flow and every flow value is spotting.
  static bool isSpottingDay(DayLog? log) =>
      log != null && log.flow.isNotEmpty && log.flow.every((flow) => flow == spottingFlow);

  /// Groups logged bleed days into spans, oldest first. A single missing day
  /// (for example an unlogged day inside a period) is bridged so one forgotten
  /// entry cannot split a period into two starts and invent a short cycle.
  static List<PeriodSpan> spans(Map<DateTime, DayLog> logs) {
    final byDay = <DateTime, DayLog>{for (final e in logs.entries) _day(e.key): e.value};
    final dates = byDay.entries.where((e) => isBleedDay(e.value)).map((e) => e.key).toList()..sort();
    final result = <PeriodSpan>[];
    for (final date in dates) {
      final spotting = isSpottingDay(byDay[date]);
      if (result.isNotEmpty && CycleCalculator.daysBetween(result.last.end, date) <= 2) {
        final previous = result.last;
        result[result.length - 1] = PeriodSpan(
          start: previous.start,
          end: date,
          spottingOnly: previous.spottingOnly && spotting,
        );
      } else {
        result.add(PeriodSpan(start: date, end: date, spottingOnly: spotting));
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
    final realPeriods = [
      for (final span in real)
        if (!span.spottingOnly && span.length >= minSpanDays) span,
    ];
    final byStart = <DateTime, PeriodSpan>{};
    for (final record in records) {
      final start = _day(record.start);
      final end = _day(record.end ?? record.start);
      final overlapsReal = realPeriods.any(
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
      final key = _day(span.start);
      final existing = byStart[key];
      final isPeriod = !span.spottingOnly && span.length >= minSpanDays;
      // A qualifying real period wins over an explicit record; a spotting or
      // too-short day never replaces an explicit period start on the same day.
      if (!isPeriod && existing != null) continue;
      byStart[key] = span;
    }
    return byStart.values.toList()..sort((a, b) => a.start.compareTo(b.start));
  }

  /// Starts of real periods only: spans shorter than [minSpanDays] are spotting
  /// and never seed cycle math, BBT baselines or OPK luteal estimates.
  static const int minSpanDays = 2;

  /// Spans that qualify as periods: a known start, even without an end, or at
  /// least [minSpanDays] consecutive logged days with at least one non-spotting
  /// flow entry.
  static List<PeriodSpan> periods(List<PeriodSpan> spans) => [
    for (final s in spans)
      if (s.startOnly || (s.length >= minSpanDays && !s.spottingOnly)) s,
  ];

  /// Spans that are spotting rather than periods: too short, or every logged
  /// day is spotting.
  static List<PeriodSpan> spotting(List<PeriodSpan> spans) => [
    for (final s in spans)
      if (!s.startOnly && (s.spottingOnly || s.length < minSpanDays)) s,
  ];

  static List<DateTime> startsOf(List<PeriodSpan> spans) => [for (final s in periods(spans)) s.start];

  /// Gaps shorter than this are rejected: they come from split periods or
  /// duplicate starts, not from a real cycle.
  static const int minCycleLength = 15;

  /// Completed cycle lengths between consecutive period starts.
  static List<int> cycleLengths(List<DateTime> starts) {
    final result = <int>[];
    for (var i = 1; i < starts.length; i++) {
      final gap = CycleCalculator.daysBetween(starts[i - 1], starts[i]);
      if (gap >= minCycleLength) result.add(gap);
    }
    return result;
  }

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
