import '../models/cycle.dart';
import '../models/cycle_stats.dart';
import '../models/period_log.dart';
import '../utils/date_utils.dart';

/// Pure, deterministic derivation of cycle history from raw period logs.
///
/// Period logs are grouped into cycles, lengths are computed between
/// consecutive period starts, and prediction accuracy is estimated by
/// comparing each actual start against the length-median forecast.
class CycleHistoryService {
  /// Consecutive logged days further apart than this are treated as a new
  /// period (and therefore a new cycle).
  static const int kMaxDaysWithinPeriod = 4;

  /// Groups sorted period log dates into cycles.
  ///
  /// The last (ongoing) cycle has no [Cycle.length] until the next period
  /// starts. Cycles are returned oldest-first.
  List<Cycle> deriveCycles(List<PeriodLog> logs) {
    final List<DateTime> days = logs.map((PeriodLog l) => dateOnly(l.date)).toSet().toList()
      ..sort();
    if (days.isEmpty) return <Cycle>[];

    final List<List<DateTime>> blocks = <List<DateTime>>[<DateTime>[days.first]];
    for (int i = 1; i < days.length; i++) {
      final DateTime previous = days[i - 1];
      final DateTime current = days[i];
      if (daysBetween(previous, current) <= kMaxDaysWithinPeriod) {
        blocks.last.add(current);
      } else {
        blocks.add(<DateTime>[current]);
      }
    }

    final List<Cycle> cycles = <Cycle>[];
    for (int i = 0; i < blocks.length; i++) {
      final DateTime start = blocks[i].first;
      final bool completed = i + 1 < blocks.length;
      final int? length = completed ? daysBetween(start, blocks[i + 1].first) : null;
      cycles.add(
        Cycle(
          id: 'cycle-$i',
          startDate: start,
          endDate: completed ? addDays(blocks[i + 1].first, -1) : null,
          length: length,
        ),
      );
    }
    return cycles;
  }

  /// Aggregate length metrics over completed cycles.
  CycleMetrics computeMetrics(List<Cycle> cycles) {
    final List<int> lengths = _completedLengths(cycles);
    if (lengths.isEmpty) {
      return const CycleMetrics(cycleCount: 0);
    }
    final double avg =
        lengths.fold<int>(0, (int s, int v) => s + v) / lengths.length;
    return CycleMetrics(
      cycleCount: lengths.length,
      averageLength: avg,
      shortestLength: lengths.first,
      longestLength: lengths.last,
    );
  }

  /// Chart points (start date, length) for completed cycles, oldest first.
  List<CycleLengthPoint> cycleLengthPoints(List<Cycle> cycles) {
    final List<Cycle> sorted = List<Cycle>.from(cycles)
      ..sort((Cycle a, Cycle b) => a.startDate.compareTo(b.startDate));
    return [
      for (final Cycle cycle in sorted)
        if (cycle.length != null)
          CycleLengthPoint(startDate: cycle.startDate, length: cycle.length!),
    ];
  }

  /// Estimates prediction accuracy using the median length as the forecast.
  PredictionAccuracy computePredictionAccuracy(List<Cycle> cycles) {
    final List<int> lengths = _completedLengths(cycles);
    if (lengths.length < 2) {
      return const PredictionAccuracy(comparisonCount: 0);
    }

    final int median = lengths[lengths.length ~/ 2];
    final List<Cycle> sorted = List<Cycle>.from(cycles)
      ..sort((Cycle a, Cycle b) => a.startDate.compareTo(b.startDate));

    final List<int> errors = <int>[];
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i - 1].length == null) break;
      final DateTime predicted = addDays(sorted[i - 1].startDate, median);
      errors.add((daysBetween(predicted, sorted[i].startDate)).abs());
    }

    if (errors.isEmpty) return const PredictionAccuracy(comparisonCount: 0);
    final double avg = errors.fold<int>(0, (int s, int v) => s + v) / errors.length;
    return PredictionAccuracy(
      comparisonCount: errors.length,
      averageErrorDays: avg,
    );
  }

  List<int> _completedLengths(List<Cycle> cycles) {
    final List<int> lengths = cycles
        .where((Cycle c) => c.length != null && c.length! > 0)
        .map((Cycle c) => c.length!)
        .toList()
      ..sort();
    return lengths;
  }
}
