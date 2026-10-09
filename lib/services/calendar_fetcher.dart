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
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final todayDate = DateTime(now.year, now.month, now.day);
    final first = DateTime(month.year, month.month, 1);
    final leading = first.weekday - 1;
    final cells = <CalendarDayCell>[];
    for (var i = 0; i < 42; i++) {
      final offset = i - leading;
      // DateTime normalizes out-of-range days into the previous/next month.
      final date = DateTime(month.year, month.month, 1 + offset);
      final inMonth = date.month == month.month && date.year == month.year;
      if (!inMonth) {
        cells.add(CalendarDayCell(day: date.day, inMonth: false));
        continue;
      }
      final day = date.day;
      final log = logs[date];
      cells.add(
        CalendarDayCell(
          day: day,
          cycleDay: CycleCalculator.cycleDay(lastStart, date, cycleLength),
          isToday: date == todayDate,
          isPredictedPeriod: CycleCalculator.isPeriodDay(lastStart, date, cycleLength, bleedLength),
          isLoggedBleed: log != null && log.flow.isNotEmpty,
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
