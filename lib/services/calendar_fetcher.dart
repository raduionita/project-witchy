import '../models/calendar_day.dart';
import '../models/cycle_prediction.dart';
import '../models/user_profile.dart';
import '../utils/date_utils.dart';

/// Builds the calendar month grid with per-day visual states.
///
/// Produces a fixed 42-cell grid (six weeks) so the calendar keeps a stable
/// height across months. Leading/trailing cells belong to adjacent months.
class CalendarFetcher {
  /// Default calendar start-of-week, in Dart `DateTime.weekday` terms
  /// (1 = Monday … 7 = Sunday).
  static const int kDefaultFirstDayOfWeek = DateTime.monday;

  /// Builds a 42-cell grid for the month containing [month].
  ///
  /// [firstDayOfWeek] is the `DateTime.weekday` value of the week's first day
  /// (1 = Monday, 7 = Sunday) and controls the leading offset so the grid
  /// matches the locale's week start.
  List<CalendarDay> fetchMonth(
    DateTime month, {
    CyclePrediction? prediction,
    Set<DateTime> loggedPeriodDays = const <DateTime>{},
    required UserProfile profile,
    DateTime? today,
    int firstDayOfWeek = kDefaultFirstDayOfWeek,
  }) {
    final DateTime now = dateOnly(today ?? DateTime.now());
    final DateTime first = DateTime(month.year, month.month, 1);

    // Leading blank cells before day 1, based on the week start.
    final int leadOffset = (first.weekday - firstDayOfWeek) % 7;

    final int periodLength = profile.averagePeriodLength;
    final List<CalendarDay> grid = <CalendarDay>[];
    final DateTime firstOfGrid = addDays(first, -leadOffset);

    for (int i = 0; i < 42; i++) {
      final DateTime date = addDays(firstOfGrid, i);
      final bool inMonth = date.year == month.year && date.month == month.month;
      grid.add(
        CalendarDay(
          date: date,
          state: inMonth
              ? _stateFor(date, prediction, loggedPeriodDays, periodLength)
              : CalendarDayState.none,
          isToday: dateOnly(date) == now,
        ),
      );
    }
    return grid;
  }

  CalendarDayState _stateFor(
    DateTime date,
    CyclePrediction? prediction,
    Set<DateTime> loggedPeriodDays,
    int periodLength,
  ) {
    if (loggedPeriodDays.any((DateTime d) => dateOnly(d) == dateOnly(date))) {
      return CalendarDayState.period;
    }
    if (prediction == null) return CalendarDayState.none;

    if (prediction.isOvulation(date)) return CalendarDayState.ovulation;
    if (prediction.isFertile(date)) return CalendarDayState.fertile;
    if (prediction.isPredictedPeriod(date, periodLength)) {
      return CalendarDayState.predictedPeriod;
    }
    return CalendarDayState.none;
  }
}