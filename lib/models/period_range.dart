import '../services/cycle_calculator.dart';

/// A known period span: the first and the last day of bleeding.
///
/// The dates are normalized to midnight so a range built from a picker (which
/// can carry a time) always compares equal to the same day built elsewhere.
class PeriodRange {
  PeriodRange({required DateTime start, required DateTime end})
      : start = DateTime(start.year, start.month, start.day),
        end = DateTime(end.year, end.month, end.day);

  /// First day of the period.
  final DateTime start;

  /// Last day of the period.
  final DateTime end;

  /// Days covered, counting both ends.
  int get length => CycleCalculator.daysBetween(start, end) + 1;

  bool contains(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return !d.isBefore(start) && !d.isAfter(end);
  }

  /// True when the two ranges share at least one day.
  bool overlaps(PeriodRange other) =>
      !start.isAfter(other.end) && !end.isBefore(other.start);

  PeriodRange copyWith({DateTime? start, DateTime? end}) =>
      PeriodRange(start: start ?? this.start, end: end ?? this.end);

  @override
  bool operator ==(Object other) =>
      other is PeriodRange && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);

  @override
  String toString() =>
      'PeriodRange(${start.toIso8601String()} - ${end.toIso8601String()})';
}
