import 'package:flutter/foundation.dart';

import '../utils/date_utils.dart';

/// Visual state of a single calendar day.
enum CalendarDayState {
  /// No data or prediction.
  none,

  /// A day with a logged period.
  period,

  /// A predicted period day (from the forecast).
  predictedPeriod,

  /// A day within the fertile window.
  fertile,

  /// The predicted ovulation day.
  ovulation,
}

/// A single cell in the month grid.
@immutable
class CalendarDay {
  const CalendarDay({required this.date, required this.state, required this.isToday});

  /// The date this cell represents (date-only).
  final DateTime date;

  /// How the cell should render.
  final CalendarDayState state;

  /// Whether this is today's date.
  final bool isToday;

  @override
  bool operator ==(Object other) =>
      other is CalendarDay &&
      dateOnly(date) == dateOnly(other.date) &&
      state == other.state &&
      isToday == other.isToday;

  @override
  int get hashCode => Object.hash(dateOnly(date), state, isToday);
}