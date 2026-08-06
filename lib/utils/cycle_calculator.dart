import 'dart:math';
import '../models/period_cycle.dart';

class CycleCalculator {
  static double calculateFertileWindowStart(List<PeriodCycle> cycles) {
    if (cycles.isEmpty) return 14.0;
    final avgCycleLength = cycles.fold<double>(0, (sum, cycle) => sum + cycle.cycleLength) / cycles.length;
    return avgCycleLength - 14;
  }

  static double calculateFertileWindowEnd(List<PeriodCycle> cycles) {
    if (cycles.isEmpty) return 16.0;
    final avgCycleLength = cycles.fold<double>(0, (sum, cycle) => sum + cycle.cycleLength) / cycles.length;
    return avgCycleLength - 12;
  }

  static DateTime? calculateNextOvulationDate(DateTime lastPeriodStart, double cycleLength) {
    return lastPeriodStart.add(Duration(days: (cycleLength - 14).toInt()));
  }

  static DateTime? calculateNextPeriodDate(DateTime lastPeriodStart, double cycleLength) {
    return lastPeriodStart.add(Duration(days: cycleLength.toInt()));
  }

  static int calculateCycleDay(DateTime periodStart, DateTime currentDate) {
    return currentDate.difference(periodStart).inDays + 1;
  }

  static CyclePhase getCurrentPhase(DateTime periodStart, double cycleLength, DateTime currentDate) {
    final cycleDay = calculateCycleDay(periodStart, currentDate);
    final phaseInCycle = cycleDay % cycleLength.toInt();

    if (phaseInCycle <= cycleLength * 0.18) {
      return CyclePhase.period;
    } else if (phaseInCycle <= cycleLength * 0.5) {
      return CyclePhase.follicular;
    } else if (phaseInCycle <= cycleLength * 0.57) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  static List<DateTime> getFertileWindowDates(DateTime periodStart, double cycleLength) {
    final fertileStart = periodStart.add(Duration(days: (cycleLength - 16).toInt()));
    final fertileEnd = periodStart.add(Duration(days: (cycleLength - 11).toInt()));
    final dates = <DateTime>[];
    var current = fertileStart;
    while (current.isBefore(fertileEnd) || current.isAtSameMomentAs(fertileEnd)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    return dates;
  }

  static double calculatePregnancyWeeks(DateTime lastPeriodDate) {
    final weeks = DateTime.now().difference(lastPeriodDate).inDays / 7;
    return min(weeks, 40);
  }

  static String getTrimesterLabel(double weeks) {
    if (weeks <= 13) return 'First Trimester';
    if (weeks <= 27) return 'Second Trimester';
    return 'Third Trimester';
  }
}
