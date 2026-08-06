import '../models/pregnancy_status.dart';
import '../utils/date_utils.dart';

/// Pure calculation engine for pregnancy weeks/trimester/due date.
///
/// Standard gestational calendar: the due date is 40 weeks (280 days) from the
/// last menstrual period (LMP). Trimester boundaries follow the common
/// clinical split of 0–12, 13–26 and 27–40 weeks.
class PregnancyCalculator {
  PregnancyCalculator({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Duration of a full pregnancy in days (40 weeks).
  static const int kGestationDays = 280;

  /// Total gestational weeks (40).
  static const int kTotalWeeks = 40;

  /// Computes the current pregnancy status from [lmp].
  ///
  /// When [today] is omitted the injected clock is used, keeping the service
  /// deterministic for tests.
  PregnancyStatus statusFor(DateTime lmp, {DateTime? today}) {
    final DateTime start = dateOnly(lmp);
    final DateTime now = dateOnly(today ?? _now());

    final DateTime dueDate = addDays(start, kGestationDays);
    final int elapsed = daysBetween(start, now).clamp(0, kGestationDays);

    final int weeks = elapsed ~/ 7;
    final int days = elapsed % 7;

    return PregnancyStatus(
      lmp: start,
      dueDate: dueDate,
      weeks: weeks,
      days: days,
      trimester: trimesterFor(weeks),
    );
  }

  /// Which trimester [weeks] falls into (0–12 first, 13–26 second, 27+ third).
  Trimester trimesterFor(int weeks) {
    if (weeks < 13) return Trimester.first;
    if (weeks < 27) return Trimester.second;
    return Trimester.third;
  }

  /// Percentage of the pregnancy completed (0–100).
  double progressPercent(PregnancyStatus status) =>
      (status.totalDays / kGestationDays * 100).clamp(0, 100);

  /// Whether [today] is at or past the estimated due date.
  bool isPastDue(PregnancyStatus status, {DateTime? today}) =>
      !dateOnly(today ?? _now()).isBefore(status.dueDate);
}