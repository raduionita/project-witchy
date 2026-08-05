import 'dart:math' as math;
import '../models/cycle_prediction.dart';
import '../models/user_settings.dart';
import 'period_tracking_service.dart';

class FertilityService {
  final PeriodTrackingService _periodService;

  FertilityService(this._periodService);

  CyclePrediction predictNextCycle({UserSettings? settings}) {
    final averageCycleLength = settings?.averageCycleLength ?? _periodService.getAverageCycleLength();
    final averagePeriodDuration = settings?.averagePeriodDuration ?? _periodService.getAveragePeriodDuration();

    final cycles = _periodService.cycles;
    final lastPeriod = cycles.isNotEmpty ? cycles.first : null;

    final now = DateTime.now();

    DateTime predictedStartDate;
    if (lastPeriod != null && !lastPeriod.isActive) {
      predictedStartDate = lastPeriod.startDate.add(Duration(days: averageCycleLength.toInt()));
    } else {
      predictedStartDate = now.add(Duration(days: averageCycleLength.toInt()));
    }

    final predictedEndDate = predictedStartDate.add(Duration(days: averagePeriodDuration.toInt() - 1));

    final fertileWindows = _calculateFertileWindows(predictedStartDate, averageCycleLength);

    final confidence = _calculateConfidence(averageCycleLength, settings?.cycleLengthVariation ?? 7.0);

    return CyclePrediction(
      predictedStartDate: predictedStartDate,
      predictedEndDate: predictedEndDate,
      cycleLength: averageCycleLength,
      predictionConfidence: confidence,
      fertileWindows: fertileWindows,
    );
  }

  List<FertileWindow> _calculateFertileWindows(DateTime periodStart, double cycleLength) {
    final ovulationDay = cycleLength - 14;
    final fertileWindowStart = periodStart.add(Duration(days: ovulationDay.toInt() - 5));
    final fertileWindowEnd = periodStart.add(Duration(days: ovulationDay.toInt() + 1));

    return [
      FertileWindow(
        startDate: fertileWindowStart,
        endDate: fertileWindowEnd,
        fertilityLevel: 0.9,
      ),
    ];
  }

  double _calculateConfidence(double averageCycleLength, double variation) {
    final cycleCount = _periodService.cycles.length;

    if (cycleCount < 2) return 0.3;

    final baseConfidence = math.min(0.3 + (cycleCount * 0.1), 0.95);
    final variationPenalty = variation / 20.0;

    return (baseConfidence * (1.0 - variationPenalty)).clamp(0.1, 0.95);
  }

  bool isCurrentlyFertile({UserSettings? settings}) {
    final prediction = predictNextCycle(settings: settings);

    for (final window in prediction.fertileWindows) {
      if (window.isActive) return true;
    }

    return false;
  }

  DateTime? getNextOvulationDate({UserSettings? settings}) {
    final prediction = predictNextCycle(settings: settings);
    return prediction.nextOvulationDate;
  }

  int getDaysUntilOvulation({UserSettings? settings}) {
    final nextOvulation = getNextOvulationDate(settings: settings);
    if (nextOvulation == null) return -1;

    final now = DateTime.now();
    final days = nextOvulation.difference(now).inDays;

    return days > 0 ? days : -1;
  }

  double getFertilityLevelForDate(DateTime date, {UserSettings? settings}) {
    final prediction = predictNextCycle(settings: settings);

    for (final window in prediction.fertileWindows) {
      if (date.isAfter(window.startDate) && date.isBefore(window.endDate)) {
        final totalDays = window.durationInDays;
        final daysIntoWindow = date.difference(window.startDate).inDays;
        final peakDay = totalDays ~/ 2;

        final distanceFromPeak = (daysIntoWindow - peakDay).abs();
        return (1.0 - (distanceFromPeak / peakDay)).clamp(0.0, 1.0);
      }
    }

    return 0.0;
  }
}
