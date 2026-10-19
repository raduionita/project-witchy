import '../models/cycle_phase.dart';

class CycleCalculator {
  CycleCalculator._();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  // UTC-normalized so DST transitions can't skew whole-day differences.
  static DateTime _utcDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  static DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

  static int _len(int cycleLength) => cycleLength <= 0 ? 28 : cycleLength;

  static int daysBetween(DateTime from, DateTime to) => _utcDay(to).difference(_utcDay(from)).inDays;

  static int cycleDay(DateTime lastStart, DateTime today, int cycleLength) =>
      (daysBetween(lastStart, today) % _len(cycleLength)) + 1;

  static DateTime cycleStart(DateTime lastStart, DateTime today, int cycleLength) {
    final since = daysBetween(lastStart, today);
    return _addDays(_day(lastStart), since - (since % _len(cycleLength)));
  }

  static DateTime nextPeriodStart(DateTime lastStart, DateTime today, int cycleLength) =>
      _addDays(cycleStart(lastStart, today, cycleLength), _len(cycleLength));

  static int daysUntilPeriod(DateTime lastStart, DateTime today, int cycleLength) =>
      daysBetween(today, nextPeriodStart(lastStart, today, cycleLength));

  static int bleedDay(DateTime lastStart, DateTime today, int cycleLength, int bleedLength) {
    final day = cycleDay(lastStart, today, cycleLength);
    return day <= bleedLength ? day : 0;
  }

  /// Cycle day of ovulation, counted back [lutealLength] days from the next
  /// start (default 14 - the population average; pass the BBT-measured
  /// personal length when available).
  static int ovulationCycleDay(int cycleLength, {int lutealLength = 14}) {
    final day = _len(cycleLength) - lutealLength;
    return day < 1 ? 1 : day;
  }

  static DateTime ovulationDay(DateTime lastStart, DateTime today, int cycleLength, {int lutealLength = 14}) =>
      _addDays(cycleStart(lastStart, today, cycleLength), ovulationCycleDay(cycleLength, lutealLength: lutealLength) - 1);

  /// Next ovulation that is still ahead of [today]; when this cycle's peak has
  /// already passed it rolls into the following cycle, so the date always agrees
  /// with [daysUntilOvulation].
  static DateTime nextOvulationDay(DateTime lastStart, DateTime today, int cycleLength, {int lutealLength = 14}) {
    final ovu = ovulationDay(lastStart, today, cycleLength, lutealLength: lutealLength);
    return daysBetween(today, ovu) >= 0 ? ovu : _addDays(ovu, _len(cycleLength));
  }

  static int daysUntilOvulation(DateTime lastStart, DateTime today, int cycleLength, {int lutealLength = 14}) =>
      daysBetween(today, nextOvulationDay(lastStart, today, cycleLength, lutealLength: lutealLength));

  /// First fertile cycle day: 5 days before ovulation (sperm survival).
  /// Never below 1. Uncertainty is carried as copy, not by widening the window.
  static int fertileStartCycleDay(int cycleLength, {int lutealLength = 14}) {
    final day = ovulationCycleDay(cycleLength, lutealLength: lutealLength) - 5;
    return day < 1 ? 1 : day;
  }

  /// Last fertile cycle day: 1 day after ovulation (egg survival).
  static int fertileEndCycleDay(int cycleLength, {int lutealLength = 14}) =>
      ovulationCycleDay(cycleLength, lutealLength: lutealLength) + 1;

  static bool isPeriodDay(DateTime lastStart, DateTime date, int cycleLength, int bleedLength) =>
      (daysBetween(lastStart, date) % _len(cycleLength)) < bleedLength;

  static bool isFertileDay(DateTime lastStart, DateTime date, int cycleLength, {int lutealLength = 14}) {
    final day = (daysBetween(lastStart, date) % _len(cycleLength)) + 1;
    return day >= fertileStartCycleDay(cycleLength, lutealLength: lutealLength) &&
        day <= fertileEndCycleDay(cycleLength, lutealLength: lutealLength);
  }

  static bool isOvulationDay(DateTime lastStart, DateTime date, int cycleLength, {int lutealLength = 14}) =>
      (daysBetween(lastStart, date) % _len(cycleLength)) + 1 ==
      ovulationCycleDay(cycleLength, lutealLength: lutealLength);

  static CyclePhase phaseAt(DateTime lastStart, DateTime date, int cycleLength, int bleedLength, {int lutealLength = 14}) {
    if (isPeriodDay(lastStart, date, cycleLength, bleedLength)) return CyclePhase.menstrual;
    if (isOvulationDay(lastStart, date, cycleLength, lutealLength: lutealLength)) return CyclePhase.ovulatory;
    if (isFertileDay(lastStart, date, cycleLength, lutealLength: lutealLength)) return CyclePhase.fertile;
    return cycleDay(lastStart, date, cycleLength) < ovulationCycleDay(cycleLength, lutealLength: lutealLength)
        ? CyclePhase.follicular
        : CyclePhase.luteal;
  }

  static String phase(DateTime lastStart, DateTime today, int cycleLength, int bleedLength, {int lutealLength = 14}) =>
      phaseAt(lastStart, today, cycleLength, bleedLength, lutealLength: lutealLength).label;

  static Set<int> periodDaysInMonth(DateTime lastStart, DateTime month, int cycleLength, int bleedLength) =>
      _daysWhere(month, (date) => isPeriodDay(lastStart, date, cycleLength, bleedLength));

  static Set<int> fertileDaysInMonth(DateTime lastStart, DateTime month, int cycleLength, {int lutealLength = 14}) =>
      _daysWhere(month, (date) => isFertileDay(lastStart, date, cycleLength, lutealLength: lutealLength));

  static Set<int> _daysWhere(DateTime month, bool Function(DateTime date) test) {
    final days = <int>{};
    final count = DateTime(month.year, month.month + 1, 0).day;
    for (var d = 1; d <= count; d++) {
      if (test(DateTime(month.year, month.month, d))) days.add(d);
    }
    return days;
  }
}
