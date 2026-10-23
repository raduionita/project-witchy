import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/services/cycle_calculator.dart';

void main() {
  group('calendar day arithmetic', () {
    test('crosses leap day without drifting', () {
      expect(CycleCalculator.daysBetween(DateTime(2024, 2, 28), DateTime(2024, 3, 1)), 2);
      expect(CycleCalculator.daysBetween(DateTime(2024, 2, 29), DateTime(2024, 3, 1)), 1);
      expect(CycleCalculator.daysBetween(DateTime(2023, 2, 28), DateTime(2023, 3, 1)), 1);
    });

    test('crosses both US daylight-saving boundaries without drifting', () {
      // Spring forward: 2024-03-10. Fall back: 2024-11-03.
      expect(CycleCalculator.daysBetween(DateTime(2024, 3, 9), DateTime(2024, 3, 11)), 2);
      expect(CycleCalculator.daysBetween(DateTime(2024, 11, 2), DateTime(2024, 11, 4)), 2);
    });
  });

  group('cycle position properties', () {
    test('cycle day and elapsed day agree for every offset across common lengths', () {
      final lastStart = DateTime(2024, 1, 1);
      for (final length in [15, 20, 28, 30, 45, 60]) {
        for (var offset = 0; offset < length * 3; offset++) {
          final today = DateTime(2024, 1, 1 + offset);
          final day = CycleCalculator.cycleDay(lastStart, today, length);
          final elapsed = CycleCalculator.elapsedCycleDay(lastStart, today);

          expect(day, offset % length + 1, reason: 'length $length offset $offset');
          expect(elapsed, offset + 1, reason: 'length $length offset $offset');
        }
      }
    });

    test('cycle start and next period start bracket every date', () {
      final lastStart = DateTime(2024, 1, 1);
      for (final length in [15, 28, 60]) {
        for (var offset = 0; offset < length * 2; offset++) {
          final today = DateTime(2024, 1, 1 + offset);
          final start = CycleCalculator.cycleStart(lastStart, today, length);
          final next = CycleCalculator.nextPeriodStart(lastStart, today, length);
          final intoCycle = CycleCalculator.daysBetween(start, today);

          expect(intoCycle, offset % length, reason: 'length $length offset $offset');
          expect(CycleCalculator.daysBetween(start, next), length);
          expect(CycleCalculator.daysUntilPeriod(lastStart, today, length), length - intoCycle);
        }
      }
    });

    test('exactly one ovulation day and a fixed fertile-window width per cycle', () {
      final lastStart = DateTime(2024, 1, 1);
      for (final length in [15, 20, 28, 30, 45, 60]) {
        final ovulationDays = <int>[];
        final fertileDays = <int>[];
        for (var offset = 0; offset < length; offset++) {
          final today = DateTime(2024, 1, 1 + offset);
          if (CycleCalculator.isOvulationDay(lastStart, today, length)) ovulationDays.add(offset);
          if (CycleCalculator.isFertileDay(lastStart, today, length)) fertileDays.add(offset);
        }

        final startDay = CycleCalculator.fertileStartCycleDay(length);
        final endDay = CycleCalculator.fertileEndCycleDay(length);
        expect(ovulationDays, [CycleCalculator.ovulationCycleDay(length) - 1], reason: 'length $length');
        expect(fertileDays, [for (var day = startDay; day <= endDay; day++) day - 1], reason: 'length $length');
      }
    });

    test('bleed marks are exactly bleedLength days per cycle', () {
      final lastStart = DateTime(2024, 1, 1);
      for (final length in [15, 28, 45, 60]) {
        for (final bleedLength in [1, 2, 5, 10]) {
          var marked = 0;
          for (var offset = 0; offset < length; offset++) {
            final today = DateTime(2024, 1, 1 + offset);
            if (CycleCalculator.isPeriodDay(lastStart, today, length, bleedLength)) marked++;
          }
          expect(marked, bleedLength, reason: 'length $length bleed $bleedLength');
        }
      }
    });

    test('projection validity ends exactly at latest length plus grace', () {
      final lastStart = DateTime(2024, 1, 1);
      const length = 28;
      const grace = 10;
      final lastValid = DateTime(2024, 1, 1 + length + grace);
      final firstInvalid = DateTime(2024, 1, 1 + length + grace + 1);

      expect(
        CycleCalculator.projectionValid(
          lastStart: lastStart,
          today: lastValid,
          latestPlausibleLength: length,
          graceDays: grace,
        ),
        isTrue,
      );
      expect(
        CycleCalculator.projectionValid(
          lastStart: lastStart,
          today: firstInvalid,
          latestPlausibleLength: length,
          graceDays: grace,
        ),
        isFalse,
      );
    });

    test('seeded random dates keep cycle math bounded and consistent', () {
      final random = Random(20261022);
      for (var i = 0; i < 500; i++) {
        final lastStart = DateTime(2020 + random.nextInt(10), 1 + random.nextInt(12), 1 + random.nextInt(28));
        final today = DateTime(lastStart.year, lastStart.month, lastStart.day + random.nextInt(1200));
        final length = 15 + random.nextInt(46);

        final day = CycleCalculator.cycleDay(lastStart, today, length);
        final elapsed = CycleCalculator.elapsedCycleDay(lastStart, today);
        final start = CycleCalculator.cycleStart(lastStart, today, length);
        final next = CycleCalculator.nextPeriodStart(lastStart, today, length);

        expect(day, inInclusiveRange(1, length));
        expect(elapsed, greaterThanOrEqualTo(1));
        expect(day, (elapsed - 1) % length + 1);
        expect(CycleCalculator.daysBetween(start, today), lessThan(length));
        expect(CycleCalculator.daysBetween(start, today), greaterThanOrEqualTo(0));
        expect(CycleCalculator.daysBetween(start, next), length);
      }
    });
  });

  group('month sets across leap February', () {
    test('period and fertile day sets mark only days that satisfy the rules', () {
      final lastStart = DateTime(2024, 2, 1);
      final periodDays = CycleCalculator.periodDaysInMonth(lastStart, DateTime(2024, 2), 28, 5);
      final fertileDays = CycleCalculator.fertileDaysInMonth(lastStart, DateTime(2024, 2), 28);

      expect(periodDays, containsAll([1, 2, 3, 4, 5]));
      expect(fertileDays, containsAll([9, 10, 11, 12, 13, 14, 15]));
      expect(fertileDays, isNot(contains(8)));
      expect(fertileDays, isNot(contains(16)));
      for (final day in periodDays) {
        expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2024, 2, day), 28, 5), isTrue);
      }
      for (final day in fertileDays) {
        expect(CycleCalculator.isFertileDay(lastStart, DateTime(2024, 2, day), 28), isTrue);
      }
    });
  });
}
