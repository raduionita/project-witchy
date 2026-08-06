import '../models/cycle.dart';
import '../models/cycle_phase.dart';
import '../models/cycle_prediction.dart';
import '../models/symptom_insights.dart';
import '../models/symptom_log.dart';
import '../utils/date_utils.dart';
import 'cycle_calculator.dart';

/// Direction of a symptom's occurrence trend over the logged timeline.
enum SymptomTrend { increasing, stable, decreasing, insufficient }

/// Pure, testable symptom analysis.
///
/// Aggregates logged [SymptomLog]s into [SymptomInsights] and maps symptoms to
/// cycle phases / day indexes using the cycle engine.
class SymptomPatternService {
  SymptomPatternService({CycleCalculator? calculator})
      : _calculator = calculator ?? CycleCalculator();

  final CycleCalculator _calculator;

  /// Aggregates symptom counts from [logs], newest days first.
  SymptomInsights analyze({required List<SymptomLog> logs, int limit = 5}) {
    if (logs.isEmpty) return SymptomInsights.empty;

    final Map<String, int> counts = <String, int>{};
    for (final SymptomLog log in logs) {
      for (final String symptom in log.symptoms) {
        counts.update(symptom, (int v) => v + 1, ifAbsent: () => 1);
      }
    }

    final List<SymptomFrequency> top = counts.entries
        .map((MapEntry<String, int> e) => SymptomFrequency(symptom: e.key, count: e.value))
        .toList()
      ..sort((SymptomFrequency a, SymptomFrequency b) => b.count.compareTo(a.count));

    return SymptomInsights(
      totalLogs: logs.length,
      totalSymptomCount: counts.values.fold<int>(0, (int sum, int v) => sum + v),
      topSymptoms: top.take(limit).toList(),
    );
  }

  /// Logs that include [symptom].
  List<SymptomLog> logsForSymptom(String symptom, List<SymptomLog> logs) =>
      logs.where((SymptomLog log) => log.symptoms.contains(symptom)).toList();

  /// Trend direction for [symptom]: compares the occurrence density (matches
  /// per logged day) in the newer half of the timeline against the older half.
  ///
  /// Returns [SymptomTrend.insufficient] when there are too few matches to
  /// judge reliably.
  SymptomTrend trendFor({required String symptom, required List<SymptomLog> logs}) {
    final List<SymptomLog> sorted = List<SymptomLog>.from(logs)
      ..sort((SymptomLog a, SymptomLog b) => a.date.compareTo(b.date));
    final List<SymptomLog> matching = logsForSymptom(symptom, sorted);
    if (matching.length < 4 || sorted.length < 4) {
      return SymptomTrend.insufficient;
    }

    final int midpoint = sorted.length ~/ 2;
    final List<SymptomLog> older = sorted.sublist(0, midpoint);
    final List<SymptomLog> newer = sorted.sublist(midpoint);

    final double olderDensity = _density(matching, older);
    final double newerDensity = _density(matching, newer);

    if (newerDensity > olderDensity * 1.2) return SymptomTrend.increasing;
    if (newerDensity < olderDensity * 0.8) return SymptomTrend.decreasing;
    return SymptomTrend.stable;
  }

  double _density(List<SymptomLog> matching, List<SymptomLog> window) {
    if (window.isEmpty) return 0;
    int count = 0;
    for (final SymptomLog log in window) {
      if (matching.any((SymptomLog m) => dateOnly(m.date) == dateOnly(log.date))) {
        count++;
      }
    }
    return count / window.length;
  }

  /// Frequency of [symptom] broken down by cycle phase.
  SymptomPhaseBreakdown breakdownByPhase({
    required String symptom,
    required List<SymptomLog> logs,
    required List<Cycle> cycles,
    CyclePrediction? currentPrediction,
  }) {
    final List<SymptomLog> matching = logsForSymptom(symptom, logs);
    final Map<CyclePhase, int> byPhase = <CyclePhase, int>{};

    for (final SymptomLog log in matching) {
      final CyclePhase? phase = _phaseFor(log.date, cycles, currentPrediction);
      if (phase == null) continue;
      byPhase.update(phase, (int v) => v + 1, ifAbsent: () => 1);
    }

    return SymptomPhaseBreakdown(
      symptom: symptom,
      total: matching.length,
      byPhase: byPhase,
    );
  }

  /// Cycle-relative day indexes on which [symptom] occurred (1-based cycle day).
  List<int> dayIndexesForSymptom({
    required String symptom,
    required List<SymptomLog> logs,
    required List<Cycle> cycles,
    CyclePrediction? currentPrediction,
  }) {
    final List<int> indexes = <int>[];
    for (final SymptomLog log in logsForSymptom(symptom, logs)) {
      final DateTime? cycleStart =
          _cycleStartFor(log.date, cycles, currentPrediction);
      if (cycleStart == null) continue;
      indexes.add(daysBetween(cycleStart, log.date) + 1);
    }
    indexes.sort();
    return indexes;
  }

  /// Maps a date to the cycle phase it belongs to.
  CyclePhase? _phaseFor(
    DateTime date,
    List<Cycle> cycles,
    CyclePrediction? currentPrediction,
  ) {
    final DateTime? cycleStart =
        _cycleStartFor(date, cycles, currentPrediction);
    if (cycleStart == null) return null;

    final CyclePrediction? local = currentPrediction;
    final int ovulationIndex = local == null
        ? 14
        : daysBetween(local.currentCycleStart, local.ovulationDay);

    return _calculator.phaseAt(
      dayIndex: daysBetween(cycleStart, date),
      periodLength: 5,
      ovulationDayIndex: ovulationIndex,
    );
  }

  /// The start date of the cycle containing [date], or null when unknown.
  DateTime? _cycleStartFor(
    DateTime date,
    List<Cycle> cycles,
    CyclePrediction? currentPrediction,
  ) {
    final List<Cycle> sorted = List<Cycle>.from(cycles)
      ..sort((Cycle a, Cycle b) => a.startDate.compareTo(b.startDate));

    // Find the last cycle that starts on or before the date.
    for (int i = sorted.length - 1; i >= 0; i--) {
      final Cycle cycle = sorted[i];
      final DateTime end = i + 1 < sorted.length
          ? sorted[i + 1].startDate
          : currentPrediction?.nextPeriodStart ?? cycle.startDate.add(const Duration(days: 40));
      if (!dateOnly(cycle.startDate).isAfter(dateOnly(date)) &&
          dateOnly(date).isBefore(dateOnly(end))) {
        return dateOnly(cycle.startDate);
      }
    }

    // Fall back to the current cycle when nothing historical matches.
    if (currentPrediction != null &&
        !currentPrediction.currentCycleStart.isAfter(dateOnly(date))) {
      return dateOnly(currentPrediction.currentCycleStart);
    }
    return null;
  }
}