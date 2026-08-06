import 'dart:math';
import '../models/period_cycle.dart';
import '../models/fertility_prediction.dart';
import '../models/pregnancy_tracker.dart';

class CycleService {
  static const int kDefaultCycleLength = 28;
  static const int kDefaultPeriodDuration = 5;
  static const int kFertileWindowDays = 6;

  DateTime? calculateNextPeriodDate(DateTime lastPeriodStart, int cycleLength) {
    return lastPeriodStart.add(Duration(days: cycleLength));
  }

  DateTime? calculateOvulationDate(DateTime lastPeriodStart, int cycleLength) {
    return lastPeriodStart.add(Duration(days: cycleLength - 14));
  }

  (DateTime, DateTime) calculateFertileWindow(DateTime lastPeriodStart, int cycleLength) {
    final ovulationDate = calculateOvulationDate(lastPeriodStart, cycleLength);
    if (ovulationDate == null) return (DateTime.now(), DateTime.now());

    final fertileStart = ovulationDate.subtract(Duration(days: 5));
    final fertileEnd = ovulationDate.add(Duration(days: 1));
    return (fertileStart, fertileEnd);
  }

  FertilityPrediction predictFertility(
    DateTime lastPeriodStart,
    int cycleLength,
  ) {
    final (fertileStart, fertileEnd) = calculateFertileWindow(lastPeriodStart, cycleLength);
    final ovulationDate = calculateOvulationDate(lastPeriodStart, cycleLength);

    final fertilityDays = <FertilityDay>[];
    for (int i = 0; i < cycleLength; i++) {
      final dayDate = lastPeriodStart.add(Duration(days: i));
      final isFertile = dayDate.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
          dayDate.isBefore(fertileEnd.add(const Duration(days: 1)));
      final isOvulationDay = ovulationDate != null && _isSameDay(dayDate, ovulationDate);

      double score = 0.0;
      if (isOvulationDay) {
        score = 1.0;
      } else if (isFertile) {
        final daysToOvulation = ovulationDate != null
            ? ovulationDate.difference(dayDate).inDays
            : 0;
        score = max(0.1, 1.0 - (daysToOvulation * 0.15));
      }

      fertilityDays.add(FertilityDay(
        date: dayDate,
        fertilityScore: score,
        isFertile: isFertile,
        isOvulation: isOvulationDay,
      ));
    }

    return FertilityPrediction(
      id: 'fertility_${lastPeriodStart.millisecondsSinceEpoch}',
      cycleStartDate: lastPeriodStart,
      cycleLength: cycleLength,
      ovulationDate: ovulationDate,
      fertileWindowStart: fertileStart,
      fertileWindowEnd: fertileEnd,
      fertilityScore: fertilityDays.where((d) => d.isFertile).length / cycleLength,
      fertilityDays: fertilityDays,
    );
  }

  PregnancyTracker calculatePregnancyTracker(
    DateTime lastPeriodDate,
    int cycleLength,
  ) {
    final now = DateTime.now();
    final daysSinceLastPeriod = now.difference(lastPeriodDate).inDays;
    final gestationalWeek = daysSinceLastPeriod ~/ 7;
    final gestationalDay = daysSinceLastPeriod % 7;
    final dueDate = lastPeriodDate.add(Duration(days: cycleLength + 280));
    final trimester = gestationalWeek < 13
        ? 'First'
        : gestationalWeek < 27
            ? 'Second'
            : 'Third';

    return PregnancyTracker(
      id: 'pregnancy_${lastPeriodDate.millisecondsSinceEpoch}',
      lastPeriodDate: lastPeriodDate,
      cycleLength: cycleLength,
      gestationalWeek: gestationalWeek,
      gestationalDay: gestationalDay,
      dueDate: dueDate,
      trimester: trimester,
    );
  }

  bool isCurrentPeriod(DateTime lastPeriodStart, int cycleLength, int periodDuration) {
    final now = DateTime.now();
    final periodEnd = lastPeriodStart.add(Duration(days: periodDuration));
    return now.isAfter(lastPeriodStart) && now.isBefore(periodEnd);
  }

  bool isFertileWindow(DateTime lastPeriodStart, int cycleLength) {
    final (fertileStart, fertileEnd) = calculateFertileWindow(lastPeriodStart, cycleLength);
    final now = DateTime.now();
    return now.isAfter(fertileStart) && now.isBefore(fertileEnd);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<PeriodCycle> generateCycleHistory({
    required int numberOfCycles,
    int averageCycleLength = kDefaultCycleLength,
  }) {
    final now = DateTime.now();
    final cycles = <PeriodCycle>[];
    DateTime currentDate = now;

    for (int i = 0; i < numberOfCycles; i++) {
      final cycleLength = averageCycleLength + Random().nextInt(4) - 2;
      final startDate = currentDate.subtract(Duration(days: cycleLength));
      final endDate = startDate.add(Duration(days: kDefaultPeriodDuration));

      cycles.add(PeriodCycle(
        id: 'cycle_${startDate.millisecondsSinceEpoch}',
        startDate: startDate,
        endDate: endDate,
        cycleLength: cycleLength,
      ));

      currentDate = startDate;
    }

    return cycles;
  }
}
