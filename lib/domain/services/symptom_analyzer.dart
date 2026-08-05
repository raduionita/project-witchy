import 'package:witchy/domain/models/daily_log.dart';

class SymptomTrendAnalyzer {
  /// Analyzes daily logs to find common symptoms.
  Map<String, int> analyzeSymptomFrequency(List<DailyLog> logs) {
    final frequencyMap = <String, int>{};

    for (var log in logs) {
      for (var symptom in log.symptoms) {
        frequencyMap[symptom] = (frequencyMap[symptom] ?? 0) + 1;
      }
    }

    return Map.fromEntries(
        frequencyMap.entries
            .where((e) => e.value > 1)
            .map((e) => MapEntry(e.key, e.value)));
  }

  Map<String, int> getFrequentSymptoms(List<DailyLog> logs) {
    final frequencyMap = <String, int>{};

    for (var log in logs) {
      for (var symptom in log.symptoms) {
        frequencyMap[symptom] = (frequencyMap[symptom] ?? 0) + 1;
      }
    }

    return Map.fromEntries(
        frequencyMap.entries
            .where((e) => e.value > 1)
            .map((e) => MapEntry(e.key, e.value)));
  }
}
