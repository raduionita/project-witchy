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
    bool showFertility = true,
    DateTime? predictedStart,
    DateTime? predictedEnd,
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
      final predicted =
          predictedStart != null && predictedEnd != null
              ? _inPredictedWindow(predictedStart, predictedEnd, date, bleedLength)
              : CycleCalculator.isPeriodDay(lastStart, date, cycleLength, bleedLength);
      cells.add(
        CalendarDayCell(
          day: day,
          cycleDay: CycleCalculator.cycleDay(lastStart, date, cycleLength),
          isToday: date == todayDate,
          isPredictedPeriod: predicted,
          isLoggedBleed: log != null && log.flow.isNotEmpty,
          isFertile: showFertility && CycleCalculator.isFertileDay(lastStart, date, cycleLength),
          isOvulation: showFertility && CycleCalculator.isOvulationDay(lastStart, date, cycleLength),
          isLogged: log != null,
          isSelected: selectedDay == day,
        ),
      );
    }
    return MonthCells(month: first, cells: cells);
  }

  /// Marks the union of possible bleed days: every day from the earliest
  /// possible start through the latest possible start + bleed length.
  static bool _inPredictedWindow(DateTime start, DateTime end, DateTime date, int bleedLength) {
    final span = CycleCalculator.daysBetween(start, end) + bleedLength;
    final off = CycleCalculator.daysBetween(start, date);
    return off >= 0 && off < span;
  }
}
