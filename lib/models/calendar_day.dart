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

/// A small data marker drawn inside a calendar day cell.
enum CalendarDayMarker {
  /// A period day was logged (bleeding).
  flow,

  /// A basal body temperature reading exists.
  bbt,

  /// An LH (ovulation) test read peak.
  lhPeak,

  /// An intimacy / intercourse record exists.
  intimacy,
}

/// A single cell in the month grid.
@immutable
class CalendarDay {
  const CalendarDay({
    required this.date,
    required this.state,
    required this.isToday,
    this.markers = const <CalendarDayMarker>[],
  });

  /// The date this cell represents (date-only).
  final DateTime date;

  /// How the cell should render.
  final CalendarDayState state;

  /// Whether this is today's date.
  final bool isToday;

  /// Small data markers drawn inside the cell (flow, BBT, LH peak, intimacy).
  final List<CalendarDayMarker> markers;

  @override
  bool operator ==(Object other) =>
      other is CalendarDay &&
      dateOnly(date) == dateOnly(other.date) &&
      state == other.state &&
      isToday == other.isToday;

  @override
  int get hashCode => Object.hash(dateOnly(date), state, isToday);
}