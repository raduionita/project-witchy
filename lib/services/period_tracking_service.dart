import '../models/period_cycle.dart';

class PeriodTrackingService {
  final List<PeriodCycle> _cycles = [];

  List<PeriodCycle> get cycles => List.unmodifiable(_cycles);

  PeriodCycle? get activePeriod =>
      _cycles.isNotEmpty && _cycles.last.endDate == null
          ? _cycles.last
          : null;

  void addPeriod({
    required DateTime startDate,
    DateTime? endDate,
    double flowIntensity = 2.0,
    List<Symptom>? symptoms,
    String? notes,
  }) {
    final newCycle = PeriodCycle(
      startDate: startDate,
      endDate: endDate,
      flowIntensity: flowIntensity,
      symptoms: symptoms,
      notes: notes,
    );

    _cycles.add(newCycle);
    _cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  void updatePeriod(PeriodCycle cycle, {DateTime? endDate}) {
    final index = _cycles.indexWhere((c) => c.key == cycle.key);
    if (index != -1) {
      _cycles[index] = cycle.copyWith(endDate: endDate);
    }
  }

  void deletePeriod(PeriodCycle cycle) {
    _cycles.removeWhere((c) => c.key == cycle.key);
  }

  void addSymptom(PeriodCycle cycle, String symptomName, {double severity = 1.0}) {
    final index = _cycles.indexWhere((c) => c.key == cycle.key);
    if (index != -1) {
      final updatedSymptoms = List<Symptom>.from(_cycles[index].symptoms);
      updatedSymptoms.add(Symptom(name: symptomName, severity: severity));
      _cycles[index] = _cycles[index].copyWith(symptoms: updatedSymptoms);
    }
  }

  void addMood(PeriodCycle cycle, Mood mood, {String? note}) {
    final index = _cycles.indexWhere((c) => c.key == cycle.key);
    if (index != -1) {
      final updatedMoods = List<MoodEntry>.from(_cycles[index].moods);
      updatedMoods.add(MoodEntry(mood: mood, note: note));
      _cycles[index] = _cycles[index].copyWith(moods: updatedMoods);
    }
  }

  void addDischargePattern(
    PeriodCycle cycle,
    DischargePattern pattern,
  ) {
    final index = _cycles.indexWhere((c) => c.key == cycle.key);
    if (index != -1) {
      final updatedPatterns = List<DischargePattern>.from(_cycles[index].dischargePatterns);
      updatedPatterns.add(pattern);
      _cycles[index] = _cycles[index].copyWith(dischargePatterns: updatedPatterns);
    }
  }

  double getAverageCycleLength() {
    if (_cycles.length < 2) return 28.0;

    double totalCycleLength = 0;
    int cycleCount = 0;

    for (var i = 0; i < _cycles.length - 1; i++) {
      final currentStart = _cycles[i].startDate;
      final nextStart = _cycles[i + 1].startDate;
      final cycleLength = currentStart.difference(nextStart).inDays.abs();

      if (cycleLength >= 14 && cycleLength <= 60) {
        totalCycleLength += cycleLength;
        cycleCount++;
      }
    }

    return cycleCount > 0 ? totalCycleLength / cycleCount : 28.0;
  }

  double getAveragePeriodDuration() {
    final completedCycles = _cycles.where((c) => c.endDate != null).toList();
    if (completedCycles.isEmpty) return 5.0;

    double totalDuration = 0;
    int count = 0;

    for (final cycle in completedCycles) {
      totalDuration += cycle.duration;
      count++;
    }

    return count > 0 ? totalDuration / count : 5.0;
  }

  List<Symptom> getAllSymptoms() {
    final Map<String, int> symptomCounts = {};

    for (final cycle in _cycles) {
      for (final symptom in cycle.symptoms) {
        symptomCounts.update(
          symptom.name,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    return symptomCounts.entries
        .map((e) => Symptom(name: e.key))
        .toList();
  }

  List<MoodEntry> getAllMoods() {
    return _cycles.expand((c) => c.moods).toList();
  }
}
