import '../models/cycle_model.dart';

/// Calculates cycle predictions and fertility insights.
class CycleService {
  /// Predicts the next [count] cycles based on average cycle length.
  static List<CycleModel> predictCycles(
    List<CycleModel> cycles,
    int count,
  ) {
    if (cycles.isEmpty) return [];

    final avgLength = _averageCycleLength(cycles);
    final lastCycle = cycles.last;
    final predictions = <CycleModel>[];

    for (var i = 1; i <= count; i++) {
      final startDate = lastCycle.nextCycleStart.add(
        Duration(days: (i - 1) * (avgLength - lastCycle.cycleLength)),
      );
      predictions.add(CycleModel(
        id: -i, // Negative IDs for predicted cycles
        startDate: startDate,
        cycleLength: avgLength,
        isPredicted: true,
      ));
    }

    return predictions;
  }

  /// Estimates the average cycle length from recorded cycles.
  static int _averageCycleLength(List<CycleModel> cycles) {
    if (cycles.isEmpty) return 28;
    final total = cycles.fold<int>(
      0,
      (sum, c) => sum + c.cycleLength,
    );
    return (total / cycles.length).round();
  }

  /// Returns the phase of the cycle for a given date.
  static CyclePhase getPhase(
    CycleModel cycle,
    DateTime date,
  ) {
    final dayInCycle = date.difference(cycle.startDate).inDays;

    if (dayInCycle < 0) return CyclePhase.preCycle;

    final periodEnd = cycle.endDate ?? cycle.startDate.add(const Duration(days: 5));
    final periodDays = periodEnd.difference(cycle.startDate).inDays;

    if (dayInCycle <= periodDays) {
      return CyclePhase.menstruation;
    }

    final ovulationDay = cycle.ovulationDay.difference(cycle.startDate).inDays;

    if (dayInCycle <= ovulationDay) {
      return CyclePhase.follicular;
    }

    if (dayInCycle <= ovulationDay + 2) {
      return CyclePhase.ovulation;
    }

    return CyclePhase.luteal;
  }

  /// Calculates the estimated due date for pregnancy.
  static DateTime estimateDueDate(DateTime lastPeriodStart) {
    return lastPeriodStart.add(const Duration(days: 280));
  }

  /// Returns the week of pregnancy given the last period start date.
  static int pregnancyWeek(DateTime lastPeriodStart, DateTime now) {
    final daysPregnant = now.difference(lastPeriodStart).inDays;
    return (daysPregnant / 7).floor();
  }

  /// Returns the trimester of pregnancy.
  static int pregnancyTrimester(DateTime lastPeriodStart, DateTime now) {
    final weeks = pregnancyWeek(lastPeriodStart, now);
    if (weeks < 13) return 1;
    if (weeks < 27) return 2;
    return 3;
  }

  /// Checks for perimenopause indicators based on cycle irregularity.
  static PeremenopauseStatus checkPerimenopause(
    List<CycleModel> cycles,
  ) {
    if (cycles.length < 6) {
      return PeremenopauseStatus.uncertain;
    }

    final lengths = cycles.map((c) => c.cycleLength).toList();
    final avg = lengths.reduce((a, b) => a + b) / lengths.length;
    final deviations = lengths
        .map((l) => (l - avg).abs())
        .toList();
    final avgDeviation =
        deviations.reduce((a, b) => a + b) / deviations.length;

    if (avgDeviation > 9) {
      return PeremenopauseStatus.likely;
    } else if (avgDeviation > 5) {
      return PeremenopauseStatus.possible;
    }

    return PeremenopauseStatus.unlikely;
  }

  /// Identifies symptom patterns across cycles.
  static Map<SymptomType, double> findSymptomPatterns(
    List<CycleModel> cycles,
  ) {
    final patternMap = <SymptomType, double>{};

    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        final current = patternMap[symptom.type] ?? 0;
        patternMap[symptom.type] = current + (symptom.severity / 5);
      }
    }

    // Normalize by number of cycles
    for (final key in patternMap.keys) {
      patternMap[key] = patternMap[key]! / cycles.length;
    }

    return patternMap;
  }
}

/// The phase of the menstrual cycle.
enum CyclePhase {
  menstruation,
  follicular,
  ovulation,
  luteal,
  preCycle,
}

/// Perimenopause assessment status.
enum PeremenopauseStatus {
  unlikely,
  possible,
  likely,
  uncertain,
}