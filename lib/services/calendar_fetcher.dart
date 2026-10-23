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
    DateTime? fertileStart,
    DateTime? fertileEnd,
    DateTime? effectiveOvulation,
    int lutealLength = 14,
    // False once the cycle runs long (see CycleProvider.predictionsConfident):
    // predicted period/fertile/ovulation dots hide until a new bleed re-anchors.
    bool predictionsConfident = true,
    Set<DateTime> estimatedStarts = const {},
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
      final fertile =
          fertileStart != null && fertileEnd != null
              ? !date.isBefore(fertileStart) && !date.isAfter(fertileEnd)
              : CycleCalculator.isFertileDay(lastStart, date, cycleLength, lutealLength: lutealLength);
      final ovulating =
          effectiveOvulation != null
              ? CycleCalculator.daysBetween(date, effectiveOvulation) == 0
              : CycleCalculator.isOvulationDay(lastStart, date, cycleLength, lutealLength: lutealLength);
      cells.add(
        CalendarDayCell(
          day: day,
          cycleDay: CycleCalculator.cycleDay(lastStart, date, cycleLength),
          isToday: date == todayDate,
          isPredictedPeriod: predicted && predictionsConfident,
          isLoggedBleed: log != null && log.flow.isNotEmpty,
          isFertile: showFertility && predictionsConfident && fertile,
          isOvulation: showFertility && predictionsConfident && ovulating,
          isLogged: log != null,
          isSelected: selectedDay == day,
          isEstimatedStart: estimatedStarts.contains(date),
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
