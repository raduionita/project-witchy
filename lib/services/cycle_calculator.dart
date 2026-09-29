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

  static int ovulationCycleDay(int cycleLength) {
    final day = _len(cycleLength) - 14;
    return day < 1 ? 1 : day;
  }

  static DateTime ovulationDay(DateTime lastStart, DateTime today, int cycleLength) =>
      _addDays(cycleStart(lastStart, today, cycleLength), ovulationCycleDay(cycleLength) - 1);

  static int daysUntilOvulation(DateTime lastStart, DateTime today, int cycleLength) {
    final len = _len(cycleLength);
    final ovu = ovulationDay(lastStart, today, cycleLength);
    final until = daysBetween(today, ovu);
    if (until >= 0) return until;
    return daysBetween(today, _addDays(ovu, len));
  }

  static int fertileStartCycleDay(int cycleLength) {
    final day = ovulationCycleDay(cycleLength) - 2;
    return day < 1 ? 1 : day;
  }

  static int fertileEndCycleDay(int cycleLength) => ovulationCycleDay(cycleLength) + 2;

  static bool isPeriodDay(DateTime lastStart, DateTime date, int cycleLength, int bleedLength) =>
      (daysBetween(lastStart, date) % _len(cycleLength)) < bleedLength;

  static bool isFertileDay(DateTime lastStart, DateTime date, int cycleLength) {
    final day = (daysBetween(lastStart, date) % _len(cycleLength)) + 1;
    return day >= fertileStartCycleDay(cycleLength) && day <= fertileEndCycleDay(cycleLength);
  }

  static bool isOvulationDay(DateTime lastStart, DateTime date, int cycleLength) =>
      (daysBetween(lastStart, date) % _len(cycleLength)) + 1 == ovulationCycleDay(cycleLength);

  static CyclePhase phaseAt(DateTime lastStart, DateTime date, int cycleLength, int bleedLength) {
    if (isPeriodDay(lastStart, date, cycleLength, bleedLength)) return CyclePhase.menstrual;
    if (isOvulationDay(lastStart, date, cycleLength)) return CyclePhase.ovulatory;
    if (isFertileDay(lastStart, date, cycleLength)) return CyclePhase.fertile;
    return cycleDay(lastStart, date, cycleLength) < ovulationCycleDay(cycleLength) ? CyclePhase.follicular : CyclePhase.luteal;
  }

  static String phase(DateTime lastStart, DateTime today, int cycleLength, int bleedLength) =>
      phaseAt(lastStart, today, cycleLength, bleedLength).label;

  static Set<int> periodDaysInMonth(DateTime lastStart, DateTime month, int cycleLength, int bleedLength) =>
      _daysWhere(month, (date) => isPeriodDay(lastStart, date, cycleLength, bleedLength));

  static Set<int> fertileDaysInMonth(DateTime lastStart, DateTime month, int cycleLength) =>
      _daysWhere(month, (date) => isFertileDay(lastStart, date, cycleLength));

  static Set<int> _daysWhere(DateTime month, bool Function(DateTime date) test) {
    final days = <int>{};
    final count = DateTime(month.year, month.month + 1, 0).day;
    for (var d = 1; d <= count; d++) {
      if (test(DateTime(month.year, month.month, d))) days.add(d);
    }
    return days;
  }
}
