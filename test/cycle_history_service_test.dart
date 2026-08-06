import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/models/period_log.dart';
import 'package:witchy/services/cycle_history_service.dart';
import 'package:witchy/utils/date_utils.dart';

PeriodLog _log(DateTime date) =>
    PeriodLog(id: 'p-${date.day}', date: dateOnly(date), symptoms: const []);

void main() {
  late CycleHistoryService service;

  setUp(() {
    service = CycleHistoryService();
  });

  test('deriveCycles groups consecutive period days into one cycle', () {
    final cycles = service.deriveCycles([
      _log(DateTime(2026, 1, 3)),
      _log(DateTime(2026, 1, 4)),
      _log(DateTime(2026, 1, 5)),
      _log(DateTime(2026, 1, 29)),
      _log(DateTime(2026, 1, 30)),
    ]);

    expect(cycles, hasLength(2));
    expect(cycles[0].startDate, DateTime(2026, 1, 3));
    expect(cycles[0].length, daysBetween(DateTime(2026, 1, 3), DateTime(2026, 1, 29)));
    expect(cycles[1].startDate, DateTime(2026, 1, 29));
    expect(cycles[1].length, isNull); // ongoing
  });

  test('deriveCycles starts a new cycle after a long gap', () {
    final cycles = service.deriveCycles([
      _log(DateTime(2026, 1, 1)),
      _log(DateTime(2026, 1, 28)), // 27-day gap -> new period
    ]);
    expect(cycles, hasLength(2));
  });

  test('computeMetrics reports average, shortest, longest', () {
    final cycles = service.deriveCycles([
      for (final int day in [1, 28, 56, 84]) _log(DateTime(2026, 1, day)),
    ]);

    final metrics = service.computeMetrics(cycles);
    expect(metrics.cycleCount, 3);
    expect(metrics.averageLength, moreOrLessEquals(27.67, epsilon: 0.01));
    expect(metrics.shortestLength, 27);
    expect(metrics.longestLength, 28);
  });

  test('computePredictionAccuracy returns null when too few cycles', () {
    expect(service.computePredictionAccuracy(const []).averageErrorDays, isNull);
  });

  test('computePredictionAccuracy measures |predicted - actual|', () {
    // Median length = 28. Actual starts at days 1, 29, 57, 85.
    final cycles = service.deriveCycles([
      _log(DateTime(2026, 1, 1)),
      _log(DateTime(2026, 1, 29)),
      _log(DateTime(2026, 1, 57)),
      _log(DateTime(2026, 1, 85)),
    ]);
    // Derived lengths: 28, 28, 28 -> median 28.
    final accuracy = service.computePredictionAccuracy(cycles);
    expect(accuracy.comparisonCount, 3);
    expect(accuracy.averageErrorDays, 0);
  });

  test('cycleLengthPoints sorts by start date and omits ongoing cycles', () {
    final cycles = service.deriveCycles([
      _log(DateTime(2026, 2, 1)),
      _log(DateTime(2026, 1, 1)),
    ]);
    final points = service.cycleLengthPoints(cycles);
    expect(points, hasLength(1));
    expect(points.single.startDate, DateTime(2026, 1, 1));
    expect(points.single.length, 31);
  });
}