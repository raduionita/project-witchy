class CyclePrediction {
  final DateTime predictedStartDate;
  final DateTime? predictedEndDate;
  final double cycleLength;
  final double predictionConfidence;
  final List<FertileWindow> fertileWindows;

  CyclePrediction({
    required this.predictedStartDate,
    this.predictedEndDate,
    required this.cycleLength,
    this.predictionConfidence = 0.8,
    List<FertileWindow>? fertileWindows,
  }) : fertileWindows = fertileWindows ?? [];

  bool get isPredictedPeriodActive =>
      predictedEndDate == null ||
      DateTime.now().isBefore(predictedEndDate!);

  int get predictedDuration =>
      predictedEndDate != null
          ? predictedEndDate!.difference(predictedStartDate).inDays + 1
          : 14;

  DateTime? get nextOvulationDate =>
      fertileWindows.isNotEmpty ? fertileWindows.first.startDate : null;
}

class FertileWindow {
  final DateTime startDate;
  final DateTime endDate;
  final double fertilityLevel;

  FertileWindow({
    required this.startDate,
    required this.endDate,
    this.fertilityLevel = 0.9,
  });

  bool get isActive =>
      DateTime.now().isAfter(startDate) && DateTime.now().isBefore(endDate);

  int get durationInDays => endDate.difference(startDate).inDays + 1;
}
