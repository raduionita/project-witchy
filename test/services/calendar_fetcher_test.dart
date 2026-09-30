import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/services/calendar_fetcher.dart';
import 'package:witchy/models/day_log.dart';

void main() {
  group('CalendarFetcher', () {
    test('always builds 42 cells Monday-first with correct leading padding', () {
      final cells = CalendarFetcher.forMonth(
        month: DateTime(2026, 2),
        lastStart: DateTime(2026, 2, 1),
        cycleLength: 28,
        bleedLength: 5,
      );
      expect(cells.cells, hasLength(42));
      // Feb 1 2026 is a Sunday → 6 leading padding cells.
      expect(cells.cells.take(6).every((c) => !c.inMonth), isTrue);
      expect(cells.cells[6].day, 1);
      expect(cells.cells[6 + 27].day, 28);
      expect(cells.cells[34].inMonth, isFalse);
      expect(cells.cells[41].inMonth, isFalse);
    });

    test('marks predicted period, ovulation, fertile and logged bleed days', () {
      final logs = {
        DateTime(2026, 9, 10): DayLog(flow: 'Light'),
        DateTime(2026, 9, 11): DayLog(flow: 'None'),
      };
      final cells = CalendarFetcher.forMonth(
        month: DateTime(2026, 9),
        lastStart: DateTime(2026, 9, 1),
        cycleLength: 28,
        bleedLength: 5,
        logs: logs,
        selectedDay: 14,
      );
      // Sep 1 2026 is a Tuesday → day 1 sits at index 1.
      expect(cells.cellFor(1)!.isPredictedPeriod, isTrue);
      expect(cells.cellFor(14)!.isOvulation, isTrue);
      expect(cells.cellFor(14)!.isSelected, isTrue);
      final logged = cells.cellFor(10)!;
      expect(logged.isLoggedBleed, isTrue);
      expect(logged.isLogged, isTrue);
      expect(logged.isPeriod, isTrue);
      final noneLogged = cells.cellFor(11)!;
      expect(noneLogged.isLoggedBleed, isFalse);
      expect(noneLogged.isLogged, isTrue);
      expect(cells.cellFor(8)!.isPredictedPeriod, isFalse);
      expect(cells.cellFor(13)!.isFertile, isTrue);
    });

    test('logged bleed outside the predicted window still marks the cell', () {
      final cells = CalendarFetcher.forMonth(
        month: DateTime(2026, 9),
        lastStart: DateTime(2026, 9, 1),
        cycleLength: 28,
        bleedLength: 5,
        logs: {DateTime(2026, 9, 20): DayLog(flow: 'Heavy')},
      );
      final cell = cells.cellFor(20)!;
      expect(cell.isPredictedPeriod, isFalse);
      expect(cell.isLoggedBleed, isTrue);
      expect(cell.isPeriod, isTrue);
    });

    test('marks isToday only for the supplied today date', () {
      final cells = CalendarFetcher.forMonth(
        month: DateTime(2026, 9),
        lastStart: DateTime(2026, 9, 1),
        cycleLength: 28,
        bleedLength: 5,
        today: DateTime(2026, 9, 10, 15, 30),
      );
      expect(cells.cellFor(10)!.isToday, isTrue);
      expect(cells.cellFor(11)!.isToday, isFalse);
      expect(cells.cells.first.isToday, isFalse);
    });

    test('assigns in-month cycle days and leaves adjacent cells at cycleDay 0', () {
      final cells = CalendarFetcher.forMonth(
        month: DateTime(2026, 9),
        lastStart: DateTime(2026, 9, 1),
        cycleLength: 28,
        bleedLength: 5,
      );
      expect(cells.cellFor(1)!.cycleDay, 1);
      expect(cells.cellFor(15)!.cycleDay, 15);
      expect(cells.cellFor(29)!.cycleDay, 1);
      expect(cells.cellFor(30)!.cycleDay, 2);
      expect(cells.cells.first.cycleDay, 0);
      expect(cells.cells.last.cycleDay, 0);
    });

    test('adjacent cells carry real next/previous month day numbers', () {
      final cells = CalendarFetcher.forMonth(
        month: DateTime(2026, 2),
        lastStart: DateTime(2026, 2, 1),
        cycleLength: 28,
        bleedLength: 5,
      );
      expect(cells.cells.first.inMonth, isFalse);
      expect(cells.cells.first.day, 26); // Mon Jan 26.
      expect(cells.cells[41].inMonth, isFalse);
      expect(cells.cells[41].day, 8); // Sun Mar 8.
    });
  });
}
