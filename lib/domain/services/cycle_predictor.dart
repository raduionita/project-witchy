import 'package:witchy/domain/models/period_cycle.dart';

class CyclePredictor {
  /// Calculates the predicted next start date based on historical cycles.
  /// Returns null if there is insufficient data (needs at least 2 completed cycles).
  DateTime? predictNextCycleStart({required List<PeriodCycle> completedCycles}) {
    if (completedCycles.length < 2) return null;

    // Sort cycles by start date
    final sortedCycles = List<PeriodCycle>.from(completedCycles)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    // Calculate average cycle length
    double totalDays = 0;
    int count = 0;

    for (int i = 1; i < sortedCycles.length; i++) {
      final diff = sortedCycles[i].startDate.difference(sortedCycles[i - 1].startDate).inDays;
      if (diff > 0) {
        totalDays += diff;
        count++;
      }
    }

    if (count == 0) return null;

    final averageCycleLength = totalDays / count;

    // Prediction: last cycle start date + average length
    final lastCycleStart = sortedCycles.last.startDate;
    return lastCycleStart.add(Duration(days: averageCycleLength.round()));
  }
}
