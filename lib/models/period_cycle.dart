import 'package:flutter/foundation.dart';

enum CyclePhase { period, follicular, ovulation, luteal }

class PeriodCycle extends ChangeNotifier {
  final String id;
  DateTime startDate;
  DateTime? endDate;
  List<Symptom> symptoms;
  double cycleLength;
  double periodDuration;
  CyclePhase currentPhase;

  PeriodCycle({
    required this.id,
    required this.startDate,
    this.endDate,
    List<Symptom>? symptoms,
    this.cycleLength = 28.0,
    this.periodDuration = 5.0,
    this.currentPhase = CyclePhase.follicular,
  }) : symptoms = symptoms ?? [];

  void addSymptom(Symptom symptom) {
    symptoms.add(symptom);
    notifyListeners();
  }

  void removeSymptom(String symptomId) {
    symptoms.removeWhere((s) => s.id == symptomId);
    notifyListeners();
  }

  void updateEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void updateCycleLength(double length) {
    cycleLength = length;
    notifyListeners();
  }

  void updatePeriodDuration(double duration) {
    periodDuration = duration;
    notifyListeners();
  }

  CyclePhase calculateCurrentPhase() {
    final now = DateTime.now();
    final daysSinceStart = now.difference(startDate).inDays;
    final phaseInCycle = daysSinceStart % cycleLength.toInt();

    if (phaseInCycle < periodDuration.toInt()) {
      return CyclePhase.period;
    } else if (phaseInCycle < cycleLength * 0.5) {
      return CyclePhase.follicular;
    } else if (phaseInCycle < cycleLength * 0.6) {
      return CyclePhase.ovulation;
    } else {
      return CyclePhase.luteal;
    }
  }

  DateTime? getNextPeriodDate() {
    if (endDate != null) {
      return endDate!.add(Duration(days: cycleLength.toInt()));
    }
    return startDate.add(Duration(days: cycleLength.toInt()));
  }

  DateTime? getOvulationDate() {
    if (endDate != null) {
      return endDate!.add(Duration(days: (cycleLength - 14).toInt()));
    }
    return startDate.add(Duration(days: (cycleLength - 14).toInt()));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'symptoms': symptoms.map((s) => s.toJson()).toList(),
      'cycleLength': cycleLength,
      'periodDuration': periodDuration,
      'currentPhase': currentPhase.name,
    };
  }

  factory PeriodCycle.fromJson(Map<String, dynamic> json) {
    return PeriodCycle(
      id: json['id'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((s) => Symptom.fromJson(s as Map<String, dynamic>))
          .toList(),
      cycleLength: (json['cycleLength'] as num).toDouble(),
      periodDuration: (json['periodDuration'] as num).toDouble(),
      currentPhase: CyclePhase.values.firstWhere(
        (e) => e.name == json['currentPhase'],
        orElse: () => CyclePhase.follicular,
      ),
    );
  }
}

class Symptom {
  final String id;
  String name;
  int severity;
  DateTime timestamp;

  Symptom({
    required this.id,
    required this.name,
    this.severity = 3,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'severity': severity,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Symptom.fromJson(Map<String, dynamic> json) {
    return Symptom(
      id: json['id'] as String,
      name: json['name'] as String,
      severity: json['severity'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
