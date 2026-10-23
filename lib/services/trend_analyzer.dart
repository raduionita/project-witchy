import '../models/day_log.dart';
import '../models/period_span.dart';
import '../models/trend_direction.dart';
import '../models/trend_summary.dart';
import 'period_history.dart';

/// Directional comparisons over recent history. Each series compares the last
/// three values with the three before them, so a single outlier cycle does not
/// flip the label.
class TrendAnalyzer {
  static const int comparisonCount = 3;
  static const int symptomWindowDays = 30;

  static List<TrendSummary> summaries({
    required List<int> observedCycleLengths,
    required List<PeriodSpan> spans,
    required Map<DateTime, DayLog> logs,
    DateTime? today,
  }) => [
    cycleLength(observedCycleLengths),
    bleedLength(spans),
    symptoms(logs, today: today),
  ];

  static TrendSummary cycleLength(List<int> observed) {
    if (observed.length < comparisonCount * 2) {
      return const TrendSummary(
        label: 'Cycle length',
        direction: TrendDirection.insufficient,
        detail: 'Log six completed cycles',
      );
    }
    final recent = observed.sublist(observed.length - comparisonCount);
    final previous = observed.sublist(observed.length - comparisonCount * 2, observed.length - comparisonCount);
    return _compare(
      label: 'Cycle length',
      previous: previous,
      recent: recent,
      unit: 'days',
    );
  }

  static TrendSummary bleedLength(List<PeriodSpan> spans) {
    final measured = PeriodHistory.measuredPeriods(spans);
    if (measured.length < comparisonCount * 2) {
      return const TrendSummary(
        label: 'Bleed length',
        direction: TrendDirection.insufficient,
        detail: 'Log six measured periods',
      );
    }
    final recent = [for (final span in measured.sublist(measured.length - comparisonCount)) span.length];
    final previous = [
      for (final span in measured.sublist(measured.length - comparisonCount * 2, measured.length - comparisonCount)) span.length,
    ];
    return _compare(label: 'Bleed length', previous: previous, recent: recent, unit: 'days');
  }

  static TrendSummary symptoms(Map<DateTime, DayLog> logs, {DateTime? today}) {
    final end = _day(today ?? DateTime.now());
    final recentStart = _addDays(end, -(symptomWindowDays - 1));
    final previousEnd = _addDays(recentStart, -1);
    final previousStart = _addDays(previousEnd, -(symptomWindowDays - 1));
    final recent = _symptomCounts(logs, recentStart, end);
    final previous = _symptomCounts(logs, previousStart, previousEnd);
    if (recent.isEmpty && previous.isEmpty) {
      return const TrendSummary(
        label: 'Symptoms',
        direction: TrendDirection.insufficient,
        detail: 'Log symptoms for a few weeks',
      );
    }
    final recentTop = _top(recent);
    final previousTop = _top(previous);
    final recentCount = recentTop?.count ?? 0;
    final previousCount = previousTop?.count ?? 0;
    final delta = recentCount - previousCount;
    final direction = delta >= 2
        ? TrendDirection.up
        : delta <= -2
        ? TrendDirection.down
        : TrendDirection.stable;
    final detail = recentTop == null
        ? 'No symptoms in the last 30 days'
        : '${recentTop.name}: $recentCount days, was $previousCount';
    return TrendSummary(label: 'Symptoms', direction: direction, detail: detail);
  }

  static TrendSummary _compare({
    required String label,
    required List<int> previous,
    required List<int> recent,
    required String unit,
  }) {
    final previousAvg = _mean(previous);
    final recentAvg = _mean(recent);
    final delta = recentAvg - previousAvg;
    final direction = delta >= 2
        ? TrendDirection.up
        : delta <= -2
        ? TrendDirection.down
        : TrendDirection.stable;
    return TrendSummary(
      label: label,
      direction: direction,
      detail: '${previousAvg.round()} -> ${recentAvg.round()} $unit',
    );
  }

  static Map<String, int> _symptomCounts(Map<DateTime, DayLog> logs, DateTime start, DateTime end) {
    final counts = <String, int>{};
    for (final entry in logs.entries) {
      final day = _day(entry.key);
      if (day.isBefore(start) || day.isAfter(end)) continue;
      for (final symptom in entry.value.symptoms) {
        counts[symptom] = (counts[symptom] ?? 0) + 1;
      }
    }
    return counts;
  }

  static ({String name, int count})? _top(Map<String, int> counts) {
    String? name;
    var count = 0;
    for (final entry in counts.entries) {
      if (entry.value > count) {
        name = entry.key;
        count = entry.value;
      }
    }
    return name == null ? null : (name: name, count: count);
  }

  static double _mean(List<int> values) => values.reduce((a, b) => a + b) / values.length;

  static DateTime _day(DateTime date) => DateTime(date.year, date.month, date.day);

  static DateTime _addDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);
}
