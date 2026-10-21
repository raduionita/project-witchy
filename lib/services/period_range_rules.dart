import '../models/period_range.dart';
import 'cycle_calculator.dart';

/// The rules a picked period range has to satisfy. They are shared by the
/// onboarding card and by the add/edit sheet so both screens behave the same.
abstract final class PeriodRangeRules {
  /// Minimum days between two period starts.
  static const int minGapDays = 15;

  /// Shortest period the app accepts.
  static const int minLengthDays = 2;

  /// Longest period the app accepts.
  static const int maxLengthDays = 10;

  /// How many periods can be listed.
  static const int maxRanges = 7;

  /// How far back a period may be dated (two years).
  static const int maxHistoryDays = 730;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Reason [range] cannot be saved, or null when it is valid.
  ///
  /// [existing] holds the periods already stored; [editing] is the range the
  /// user is changing, which is excluded from the gap and overlap checks and
  /// from the "too many periods" check.
  static String? validate({
    required PeriodRange range,
    required List<PeriodRange> existing,
    PeriodRange? editing,
    DateTime? today,
  }) {
    final now = _day(today ?? _today());
    if (range.end.isBefore(range.start)) {
      return 'The last day cannot be before the first day.';
    }
    final length = range.length;
    if (length < minLengthDays) {
      return 'A period must be at least $minLengthDays days long.';
    }
    if (length > maxLengthDays) {
      return 'A period can be at most $maxLengthDays days long.';
    }
    if (range.end.isAfter(now)) {
      return 'Periods cannot be in the future.';
    }
    if (CycleCalculator.daysBetween(range.start, now) > maxHistoryDays) {
      return 'Only the last two years can be edited.';
    }
    final others = _others(existing, editing);
    if (others.any((other) => other.overlaps(range))) {
      return 'That range overlaps a period you already added.';
    }
    for (final other in others) {
      if (CycleCalculator.daysBetween(other.start, range.start).abs() < minGapDays) {
        return 'Keep at least $minGapDays days between period starts.';
      }
    }
    if (editing == null && existing.length >= maxRanges) {
      return 'You can add up to $maxRanges periods.';
    }
    return null;
  }

  /// True when [day] can be the first day of a period.
  static bool canStartOn(
    DateTime day, {
    List<PeriodRange> existing = const [],
    PeriodRange? editing,
    DateTime? today,
  }) {
    final now = _day(today ?? _today());
    final d = _day(day);
    if (d.isAfter(now)) return false;
    if (CycleCalculator.daysBetween(d, now) > maxHistoryDays) return false;
    for (final other in _others(existing, editing)) {
      if (CycleCalculator.daysBetween(other.start, d).abs() < minGapDays) {
        return false;
      }
    }
    return true;
  }

  /// True when [day] can be the last day of a period that starts on [start].
  ///
  /// Days before [start] are judged as new first days instead: picking one
  /// restarts the selection on that day.
  static bool canEndOn(
    DateTime day, {
    required DateTime start,
    List<PeriodRange> existing = const [],
    PeriodRange? editing,
    DateTime? today,
  }) {
    final now = _day(today ?? _today());
    final d = _day(day);
    if (d.isBefore(start)) {
      return canStartOn(d, existing: existing, editing: editing, today: now);
    }
    if (d.isAfter(now)) return false;
    if (CycleCalculator.daysBetween(start, d) + 1 > maxLengthDays) return false;
    if (CycleCalculator.daysBetween(start, d) + 1 < minLengthDays) return false;
    final candidate = PeriodRange(start: start, end: d);
    for (final other in _others(existing, editing)) {
      if (other.overlaps(candidate)) return false;
    }
    return true;
  }

  /// The stored periods without the one being edited.
  static List<PeriodRange> _others(
    List<PeriodRange> existing,
    PeriodRange? editing,
  ) {
    if (editing == null) return existing;
    return existing.where((other) => other.start != editing.start).toList();
  }
}
