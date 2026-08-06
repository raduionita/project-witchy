/// Date arithmetic helpers used by the cycle engine.
///
/// All work with date-only values (year/month/day) to avoid timezone drift
/// when computing day offsets.
library;

import 'package:flutter/foundation.dart';

/// Strips the time component, keeping only the calendar date.
DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Adds [days] days to [d], using calendar-day arithmetic so results stay at
/// midnight (DST-safe) and preserve the date-only invariant.
DateTime addDays(DateTime d, int days) =>
    DateTime(d.year, d.month, d.day + days);

/// Whole days from [a] to [b] (negative when [b] precedes [a]).
///
/// Computed in UTC to stay exact across daylight-saving transitions.
int daysBetween(DateTime a, DateTime b) => DateTime.utc(b.year, b.month, b.day)
    .difference(DateTime.utc(a.year, a.month, a.day))
    .inDays;

@immutable
class DaySpan {
  const DaySpan(this.start, this.end);

  /// Inclusive start date.
  final DateTime start;

  /// Inclusive end date.
  final DateTime end;

  /// Whether [date] falls within the span (inclusive).
  bool contains(DateTime date) =>
      !dateOnly(date).isBefore(dateOnly(start)) &&
      !dateOnly(date).isAfter(dateOnly(end));

  /// Whether this span overlaps [other] (inclusive).
  bool overlaps(DaySpan other) =>
      !dateOnly(other.start).isAfter(dateOnly(end)) &&
      !dateOnly(other.end).isBefore(dateOnly(start));

  @override
  bool operator ==(Object other) =>
      other is DaySpan &&
      dateOnly(start) == dateOnly(other.start) &&
      dateOnly(end) == dateOnly(other.end);

  @override
  int get hashCode => Object.hash(dateOnly(start), dateOnly(end));

  @override
  String toString() => 'DaySpan(${dateOnly(start)} .. ${dateOnly(end)})';
}