import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/models/cycle.dart';
import 'package:witchy/models/cycle_phase.dart';
import 'package:witchy/models/user_profile.dart';
import 'package:witchy/services/cycle_calculator.dart';
import 'package:witchy/utils/date_utils.dart';

const UserProfile kProfile28 = UserProfile(
  id: 'p1',
  averageCycleLength: 28,
  averagePeriodLength: 5,
  lutealPhaseLength: 14,
);

void main() {
  late CycleCalculator calculator;

  setUp(() {
    calculator = CycleCalculator();
  });

  group('next period prediction', () {
    test('predicts a 28-day cycle from the last logged period', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1)},
        today: DateTime(2026, 1, 15),
      );

      expect(prediction, isNotNull);
      expect(dateOnly(prediction!.nextPeriodStart), DateTime(2026, 1, 29));
    });

    test('keeps the next period in the future when the cycle is overdue', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1)},
        today: DateTime(2026, 2, 10),
      );

      // Jan 29 has passed without a new log; project to the following cycle.
      expect(dateOnly(prediction!.nextPeriodStart), DateTime(2026, 2, 26));
      expect(dateOnly(prediction.currentCycleStart), DateTime(2026, 1, 29));
    });
  });

  group('ovulation and fertile window', () {
    test('ovulation is one luteal phase before the next period', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1)},
        today: DateTime(2026, 1, 15),
      );

      expect(dateOnly(prediction!.ovulationDay), DateTime(2026, 1, 15));
    });

    test('fertile window spans 5 days before ovulation inclusive', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1)},
        today: DateTime(2026, 1, 15),
      );

      expect(prediction!.fertileWindow.start, DateTime(2026, 1, 10));
      expect(prediction.fertileWindow.end, DateTime(2026, 1, 15));
      expect(prediction.isFertile(DateTime(2026, 1, 12)), isTrue);
      expect(prediction.isFertile(DateTime(2026, 1, 9)), isFalse);
    });
  });

  group('cycle phases', () {
    test('reports menstruation while inside the logged period', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1), DateTime(2026, 1, 3)},
        today: DateTime(2026, 1, 3),
      );

      expect(prediction!.currentCyclePhase, CyclePhase.menstruation);
    });

    test('reports ovulatory on the predicted ovulation day', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1)},
        today: DateTime(2026, 1, 15),
      );

      expect(prediction!.currentCyclePhase, CyclePhase.ovulatory);
    });

    test('reports luteal after ovulation', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1)},
        today: DateTime(2026, 1, 25),
      );

      expect(prediction!.currentCyclePhase, CyclePhase.luteal);
    });

    test('phaseAt classifies a bare day index', () {
      expect(calculator.phaseAt(dayIndex: 0, periodLength: 5, ovulationDayIndex: 14),
          CyclePhase.menstruation);
      expect(calculator.phaseAt(dayIndex: 10, periodLength: 5, ovulationDayIndex: 14),
          CyclePhase.follicular);
      expect(calculator.phaseAt(dayIndex: 14, periodLength: 5, ovulationDayIndex: 14),
          CyclePhase.ovulatory);
      expect(calculator.phaseAt(dayIndex: 20, periodLength: 5, ovulationDayIndex: 14),
          CyclePhase.luteal);
    });
  });

  group('adaptive lengths', () {
    test('uses the median of completed cycles when available', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        loggedPeriodDays: {DateTime(2026, 1, 1)},
        cycles: [
          Cycle(id: 'c1', startDate: DateTime(2025, 11, 1), length: 26),
          Cycle(id: 'c2', startDate: DateTime(2025, 12, 1), length: 30),
          Cycle(id: 'c3', startDate: DateTime(2026, 1, 1), length: 28),
        ],
        today: DateTime(2026, 1, 15),
      );

      // Median length 28 -> next period Jan 29 (same as profile default).
      expect(dateOnly(prediction!.nextPeriodStart), DateTime(2026, 1, 29));
    });
  });

  group('edge cases', () {
    test('returns null without any anchor data', () {
      final prediction = calculator.predict(
        profile: kProfile28,
        today: DateTime(2026, 1, 15),
      );

      expect(prediction, isNull);
    });

    test('anchors from firstPeriodDate when nothing is logged', () {
      const UserProfile profile = UserProfile(
        id: 'p2',
        averageCycleLength: 28,
        averagePeriodLength: 5,
        lutealPhaseLength: 14,
        firstPeriodDate: null,
      );

      final prediction = calculator.predict(
        profile: profile,
        today: DateTime(2026, 1, 15),
      );

      expect(prediction, isNull);
    });

    test('resolves last start from the profile first period date', () {
      final prediction = calculator.predict(
        profile: kProfile28.copyWith(
          firstPeriodDate: DateTime(2025, 12, 1),
        ),
        today: DateTime(2026, 1, 15),
      );

      // Most recent projected start at/before Jan 15: Dec 29, next Jan 26.
      expect(dateOnly(prediction!.currentCycleStart), DateTime(2025, 12, 29));
      expect(dateOnly(prediction.nextPeriodStart), DateTime(2026, 1, 26));
    });
  });
}