import '../models/cycle.dart';
import '../models/cycle_phase.dart';
import '../models/cycle_prediction.dart';
import '../models/user_profile.dart';
import '../utils/date_utils.dart';

/// Pure calculation engine for cycle predictions.
///
/// All methods are deterministic given their inputs, making them trivially
/// unit-testable. It models the standard calendar method: ovulation occurs a
/// full luteal phase before the next period, and the fertile window includes
/// the days sperm can survive before ovulation.
class CycleCalculator {
  CycleCalculator({DateTime Function()? now}) : _now = now ?? DateTime.now;

  final DateTime Function() _now;

  /// Number of days before ovulation included in the fertile window.
  static const int fertileWindowDaysBeforeOvulation = 5;

  /// Minimum sensible cycle length in days.
  static const int kMinCycleLength = 15;

  /// Maximum sensible cycle length in days.
  static const int kMaxCycleLength = 60;

  /// Predicts the current/next cycle for [profile].
  ///
  /// Returns null when there is not enough data to anchor a cycle (no logged
  /// period, no cycle, and no first-period date on the profile).
  CyclePrediction? predict({
    required UserProfile profile,
    Set<DateTime> loggedPeriodDays = const <DateTime>{},
    List<Cycle> cycles = const <Cycle>[],
    DateTime? today,
  }) {
    final DateTime now = dateOnly(today ?? _now());

    final int cycleLen = _effectiveCycleLength(profile, cycles);
    final int luteal = _effectiveLuteal(profile).clamp(1, cycleLen - 1);
    final int periodLen = _effectivePeriodLength(profile);

    final DateTime? lastStart = _resolveLastStart(
      loggedPeriodDays: loggedPeriodDays,
      cycles: cycles,
      profile: profile,
      now: now,
    );
    if (lastStart == null) return null;

    // Anchor at the most recent period start; advance through unseen cycles
    // so the next period prediction stays in the future.
    DateTime anchorStart = lastStart;
    DateTime nextPeriod = addDays(anchorStart, cycleLen);
    int guard = 0;
    while (!dateOnly(nextPeriod).isAfter(now) && guard < 2400) {
      anchorStart = nextPeriod;
      nextPeriod = addDays(nextPeriod, cycleLen);
      guard++;
    }

    final DateTime ovulation = addDays(nextPeriod, -luteal);
    final DaySpan fertile = DaySpan(
      addDays(ovulation, -fertileWindowDaysBeforeOvulation),
      ovulation,
    );

    final int ovulationIndex = daysBetween(anchorStart, ovulation);
    final CyclePhase todayPhase = phaseAt(
      dayIndex: daysBetween(anchorStart, now),
      periodLength: periodLen.clamp(1, ovulationIndex),
      ovulationDayIndex: ovulationIndex,
    );

    return CyclePrediction(
      nextPeriodStart: nextPeriod,
      ovulationDay: ovulation,
      fertileWindow: fertile,
      currentCycleStart: anchorStart,
      currentCyclePhase: todayPhase,
    );
  }

  /// Classifies an absolute day index within a cycle.
  CyclePhase phaseAt({
    required int dayIndex,
    required int periodLength,
    required int ovulationDayIndex,
  }) {
    if (dayIndex < periodLength) return CyclePhase.menstruation;
    if (dayIndex < ovulationDayIndex) return CyclePhase.follicular;
    if (dayIndex == ovulationDayIndex) return CyclePhase.ovulatory;
    return CyclePhase.luteal;
  }

  /// Determines the most recent cycle start from logs, cycles, or the profile.
  DateTime? _resolveLastStart({
    required Set<DateTime> loggedPeriodDays,
    required List<Cycle> cycles,
    required UserProfile profile,
    required DateTime now,
  }) {
    DateTime? latest = _latestOf(loggedPeriodDays);
    final DateTime? latestCycleStart = _latestCycleStart(cycles);
    if (latest == null ||
        (latestCycleStart != null && latestCycleStart.isAfter(latest))) {
      latest = latestCycleStart;
    }

    if (latest != null) return latest;

    // No tracked data: fall back to the profile's first period date.
    final DateTime? first = profile.firstPeriodDate;
    if (first == null) return null;

    // Project forward to the most recent start at or before today.
    final int cycleLen = _effectiveCycleLength(profile, cycles);
    DateTime candidate = dateOnly(first);
    int guard = 0;
    while (daysBetween(candidate, now) >= cycleLen && guard < 1200) {
      candidate = addDays(candidate, cycleLen);
      guard++;
    }
    return candidate;
  }

  DateTime? _latestOf(Set<DateTime> dates) {
    DateTime? latest;
    for (final DateTime d in dates) {
      final DateTime day = dateOnly(d);
      if (latest == null || day.isAfter(latest)) latest = day;
    }
    return latest;
  }

  DateTime? _latestCycleStart(List<Cycle> cycles) {
    DateTime? latest;
    for (final Cycle c in cycles) {
      final DateTime s = dateOnly(c.startDate);
      if (latest == null || s.isAfter(latest)) latest = s;
    }
    return latest;
  }

  /// Median length of completed cycles, or null when none are recorded.
  int? _medianCycleLength(List<Cycle> cycles) {
    final List<int> lengths = cycles
        .where((Cycle c) => c.length != null && c.length! > 0)
        .map((Cycle c) => c.length!)
        .toList()
      ..sort();
    if (lengths.isEmpty) return null;
    return lengths[lengths.length ~/ 2];
  }

  int _effectiveCycleLength(UserProfile profile, List<Cycle> cycles) =>
      (_medianCycleLength(cycles) ?? profile.averageCycleLength)
          .clamp(kMinCycleLength, kMaxCycleLength);

  int _effectivePeriodLength(UserProfile profile) =>
      profile.averagePeriodLength.clamp(1, 15);

  int _effectiveLuteal(UserProfile profile) =>
      (profile.lutealPhaseLength > 0 ? profile.lutealPhaseLength : 14)
          .clamp(7, 16);
}