import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/cycle_phase.dart';
import 'package:witchy/services/cycle_calculator.dart';

void main() {
  final lastStart = DateTime(2026, 9, 1);

  group('cycleDay / cycleStart', () {
    test('cycle day on start date is 1', () {
      expect(CycleCalculator.cycleDay(lastStart, DateTime(2026, 9, 1), 28), 1);
    });

    test('cycle day at end of cycle', () {
      expect(CycleCalculator.cycleDay(lastStart, DateTime(2026, 9, 28), 28), 28);
    });

    test('cycle day wraps into next cycle', () {
      expect(CycleCalculator.cycleDay(lastStart, DateTime(2026, 9, 29), 28), 1);
      expect(CycleCalculator.cycleDay(lastStart, DateTime(2026, 10, 13), 28), 15);
    });

    test('today before lastStart wraps into the previous cycle', () {
      expect(CycleCalculator.cycleDay(lastStart, DateTime(2026, 8, 20), 28), 17);
      expect(CycleCalculator.cycleStart(lastStart, DateTime(2026, 8, 20), 28), DateTime(2026, 8, 4));
      expect(CycleCalculator.nextPeriodStart(lastStart, DateTime(2026, 8, 20), 28), DateTime(2026, 9, 1));
    });

    test('past dates before lastStart get period/fertile marks from earlier cycles', () {
      expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2026, 8, 5), 28, 5), isTrue);
      expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2026, 8, 9), 28, 5), isFalse);
      expect(CycleCalculator.isOvulationDay(lastStart, DateTime(2026, 8, 17), 28), isTrue);
      expect(CycleCalculator.isFertileDay(lastStart, DateTime(2026, 8, 16), 28), isTrue);
    });
  });

  group('period prediction', () {
    test('next period is one cycle after last start', () {
      expect(CycleCalculator.nextPeriodStart(lastStart, DateTime(2026, 9, 10), 28), DateTime(2026, 9, 29));
      expect(CycleCalculator.daysUntilPeriod(lastStart, DateTime(2026, 9, 10), 28), 19);
    });

    test('next period accounts for cycle wrap', () {
      expect(CycleCalculator.nextPeriodStart(lastStart, DateTime(2026, 10, 5), 28), DateTime(2026, 10, 27));
    });

    test('bleedDay counts within bleed window only', () {
      expect(CycleCalculator.bleedDay(lastStart, DateTime(2026, 9, 1), 28, 5), 1);
      expect(CycleCalculator.bleedDay(lastStart, DateTime(2026, 9, 5), 28, 5), 5);
      expect(CycleCalculator.bleedDay(lastStart, DateTime(2026, 9, 6), 28, 5), 0);
      expect(CycleCalculator.bleedDay(lastStart, DateTime(2026, 9, 29), 28, 5), 1);
    });
  });

  group('ovulation & fertility', () {
    test('ovulation cycle day for 28-day cycle matches mock (day 14)', () {
      expect(CycleCalculator.ovulationCycleDay(28), 14);
      expect(CycleCalculator.ovulationCycleDay(40), 26);
      expect(CycleCalculator.ovulationCycleDay(20), 6);
    });

    test('fertile window spans cycle days 12–16 for 28-day cycle', () {
      expect(CycleCalculator.fertileStartCycleDay(28), 12);
      expect(CycleCalculator.fertileEndCycleDay(28), 16);
    });

    test('ovulation date and days until ovulation', () {
      expect(CycleCalculator.ovulationDay(lastStart, DateTime(2026, 9, 10), 28), DateTime(2026, 9, 14));
      expect(CycleCalculator.daysUntilOvulation(lastStart, DateTime(2026, 9, 10), 28), 4);
      expect(CycleCalculator.daysUntilOvulation(lastStart, DateTime(2026, 9, 20), 28), 22);
    });

    test('isPeriodDay and isFertileDay across cycle wrap', () {
      expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2026, 9, 3), 28, 5), isTrue);
      expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2026, 10, 2), 28, 5), isTrue);
      expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2026, 10, 4), 28, 5), isFalse);
      expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2026, 10, 27), 28, 5), isTrue);
      expect(CycleCalculator.isPeriodDay(lastStart, DateTime(2026, 10, 28), 28, 5), isTrue);
      expect(CycleCalculator.isFertileDay(lastStart, DateTime(2026, 9, 13), 28), isTrue);
      expect(CycleCalculator.isFertileDay(lastStart, DateTime(2026, 9, 16), 28), isTrue);
      expect(CycleCalculator.isFertileDay(lastStart, DateTime(2026, 9, 17), 28), isFalse);
      expect(CycleCalculator.isOvulationDay(lastStart, DateTime(2026, 9, 14), 28), isTrue);
    });
  });

  group('phase', () {
    test('phase names follow mock at key days', () {
      expect(CycleCalculator.phase(lastStart, DateTime(2026, 9, 3), 28, 5), 'Shedding Tide');
      expect(CycleCalculator.phase(lastStart, DateTime(2026, 9, 8), 28, 5), 'Waxing Glow');
      expect(CycleCalculator.phase(lastStart, DateTime(2026, 9, 13), 28, 5), 'Fertile Window');
      expect(CycleCalculator.phase(lastStart, DateTime(2026, 9, 14), 28, 5), 'Full Moon Peak');
      expect(CycleCalculator.phase(lastStart, DateTime(2026, 9, 22), 28, 5), 'Waning Glow');
    });

    test('phaseAt returns enum values at key days', () {
      expect(CycleCalculator.phaseAt(lastStart, DateTime(2026, 9, 3), 28, 5), CyclePhase.menstrual);
      expect(CycleCalculator.phaseAt(lastStart, DateTime(2026, 9, 8), 28, 5), CyclePhase.follicular);
      expect(CycleCalculator.phaseAt(lastStart, DateTime(2026, 9, 13), 28, 5), CyclePhase.fertile);
      expect(CycleCalculator.phaseAt(lastStart, DateTime(2026, 9, 14), 28, 5), CyclePhase.ovulatory);
      expect(CycleCalculator.phaseAt(lastStart, DateTime(2026, 9, 22), 28, 5), CyclePhase.luteal);
    });

    test('phaseAt handles dates before lastStart via previous cycle wrap', () {
      expect(CycleCalculator.phaseAt(lastStart, DateTime(2026, 8, 5), 28, 5), CyclePhase.menstrual);
      expect(CycleCalculator.phaseAt(lastStart, DateTime(2026, 8, 20), 28, 5), CyclePhase.luteal);
    });

    test('enum labels cover all phases', () {
      expect(CyclePhase.menstrual.label, 'Shedding Tide');
      expect(CyclePhase.follicular.label, 'Waxing Glow');
      expect(CyclePhase.fertile.label, 'Fertile Window');
      expect(CyclePhase.ovulatory.label, 'Full Moon Peak');
      expect(CyclePhase.luteal.label, 'Waning Glow');
    });
  });

  group('month helpers', () {
    test('periodDaysInMonth marks bleed days of current and wrapped cycle', () {
      final periodDays = CycleCalculator.periodDaysInMonth(lastStart, DateTime(2026, 10), 28, 5);
      expect(periodDays, {1, 2, 3, 27, 28, 29, 30, 31});
    });

    test('fertileDaysInMonth marks window days', () {
      final fertileDays = CycleCalculator.fertileDaysInMonth(lastStart, DateTime(2026, 9), 28);
      expect(fertileDays, {12, 13, 14, 15, 16});
    });

    test('month helper handles short months', () {
      final periodDays = CycleCalculator.periodDaysInMonth(DateTime(2026, 2, 1), DateTime(2026, 2), 28, 5);
      expect(periodDays, {1, 2, 3, 4, 5});
      expect(CycleCalculator.fertileDaysInMonth(DateTime(2026, 2, 1), DateTime(2026, 2), 28), {12, 13, 14, 15, 16});
    });
  });
}
