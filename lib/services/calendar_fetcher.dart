import '../models/calendar_day_cell.dart';
import '../models/day_log.dart';
import '../models/month_cells.dart';
import 'cycle_calculator.dart';

class CalendarFetcher {
  CalendarFetcher._();

  static MonthCells forMonth({
    required DateTime month,
    required DateTime lastStart,
    required int cycleLength,
    required int bleedLength,
    Map<DateTime, DayLog> logs = const {},
    int? selectedDay,
  }) {
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    final cells = <CalendarDayCell>[];
    for (var i = 0; i < 42; i++) {
      final offset = i - leading;
      if (offset < 0 || offset >= dayCount) {
        cells.add(const CalendarDayCell.padding());
        continue;
      }
      final day = offset + 1;
      final date = DateTime(month.year, month.month, day);
      final log = logs[date];
      cells.add(
        CalendarDayCell(
          day: day,
          isPredictedPeriod: CycleCalculator.isPeriodDay(lastStart, date, cycleLength, bleedLength),
          isLoggedBleed: log != null && log.flow != 'None',
          isFertile: CycleCalculator.isFertileDay(lastStart, date, cycleLength),
          isOvulation: CycleCalculator.isOvulationDay(lastStart, date, cycleLength),
          isLogged: log != null,
          isSelected: selectedDay == day,
        ),
      );
    }
    return MonthCells(month: first, cells: cells);
  }
}
