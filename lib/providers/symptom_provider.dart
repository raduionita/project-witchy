import 'package:flutter/foundation.dart';
import '../models/cycle_model.dart';

/// Manages symptom recording and pattern analysis.
class SymptomProvider extends ChangeNotifier {
  final Map<DateTime, List<SymptomEntry>> _symptomMap = {};

  /// Gets all symptoms for a given date.
  List<SymptomEntry> getSymptomsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _symptomMap[key] ?? [];
  }

  /// Gets all symptoms within a date range.
  List<SymptomEntry> getSymptomsInRange(DateTime start, DateTime end) {
    final result = <SymptomEntry>[];
    for (final entry in _symptomMap.values) {
      for (final symptom in entry) {
        if (symptom.date.isAfter(start) && symptom.date.isBefore(end)) {
          result.add(symptom);
        }
      }
    }
    return result;
  }

  /// Adds a symptom entry.
  void addSymptom(SymptomEntry symptom) {
    final key = DateTime(symptom.date.year, symptom.date.month, symptom.date.day);
    _symptomMap.putIfAbsent(key, () => []).add(symptom);
    notifyListeners();
  }

  /// Removes a symptom entry.
  void removeSymptom(int symptomId) {
    for (final dateKey in _symptomMap.keys.toList()) {
      final symptoms = _symptomMap[dateKey]!;
      final index = symptoms.indexWhere((s) => s.id == symptomId);
      if (index != -1) {
        symptoms.removeAt(index);
        if (symptoms.isEmpty) {
          _symptomMap.remove(dateKey);
        }
        notifyListeners();
        return;
      }
    }
  }

  /// Gets all recorded symptoms across all cycles.
  List<SymptomEntry> get allSymptoms {
    final result = <SymptomEntry>[];
    for (final symptoms in _symptomMap.values) {
      result.addAll(symptoms);
    }
    return result;
  }

  /// Calculates the frequency of each symptom type.
  Map<SymptomType, int> getSymptomFrequency() {
    final frequency = <SymptomType, int>{};
    for (final symptom in allSymptoms) {
      frequency[symptom.type] = (frequency[symptom.type] ?? 0) + 1;
    }
    return frequency;
  }

  /// Clears all symptom data.
  void clearAll() {
    _symptomMap.clear();
    notifyListeners();
  }
}