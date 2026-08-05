import 'package:flutter/foundation.dart';
import '../models/period_cycle.dart';

class SymptomsProvider extends ChangeNotifier {
  final Map<String, List<Symptom>> _symptomLog = {};

  Map<String, List<Symptom>> get symptomLog => _symptomLog;

  void logSymptom(String dateKey, String symptomName, {double severity = 1.0}) {
    final symptom = Symptom(name: symptomName, severity: severity);

    if (_symptomLog.containsKey(dateKey)) {
      _symptomLog[dateKey]?.add(symptom);
    } else {
      _symptomLog[dateKey] = [symptom];
    }

    notifyListeners();
  }

  void removeSymptom(String dateKey, String symptomName) {
    if (_symptomLog.containsKey(dateKey)) {
      _symptomLog[dateKey]?.removeWhere((s) => s.name == symptomName);
      if (_symptomLog[dateKey]?.isEmpty ?? false) {
        _symptomLog.remove(dateKey);
      }
      notifyListeners();
    }
  }

  List<Symptom> getSymptomsForDate(String dateKey) {
    return _symptomLog[dateKey] ?? [];
  }

  List<String> getAvailableSymptoms() {
    return [
      'Cramps',
      'Headache',
      'Bloating',
      'Backache',
      'Acne',
      'Breast tenderness',
      'Fatigue',
      'Nausea',
      'Dizziness',
      'Insomnia',
      'Food cravings',
      'Diarrhea',
      'Constipation',
      'Heavy/light flow',
      'Clots',
      'Spotting between periods',
      'Emotional swings',
      'Anxiety',
      'Irritability',
      'Difficulty concentrating',
    ];
  }

  List<String> getAvailableMoods() {
    return [
      'Happy',
      'Sad',
      'Irritable',
      'Anxious',
      'Energetic',
      'Tired',
      'Focused',
      'Crampy',
      'Bloated',
      'Nauseous',
    ];
  }

  List<String> getAvailableDischargePatterns() {
    return [
      'Dry',
      'Sticky',
      'Creamy',
      'Watery',
      'Egg White',
      'Abundant',
    ];
  }
}
