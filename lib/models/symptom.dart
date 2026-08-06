import 'dart:convert';

enum SymptomType {
  cramps,
  headache,
  bloating,
  breastTenderness,
  fatigue,
  acne,
  backache,
  moodSwings,
  nausea,
  heavyFlow,
  lightFlow,
  spotting,
  none,
}

class Symptom {
  final String id;
  final SymptomType type;
  final DateTime date;
  final int severity;
  final String? notes;

  const Symptom({
    required this.id,
    required this.type,
    required this.date,
    this.severity = 1,
    this.notes,
  });

  Symptom copyWith({
    String? id,
    SymptomType? type,
    DateTime? date,
    int? severity,
    String? notes,
  }) {
    return Symptom(
      id: id ?? this.id,
      type: type ?? this.type,
      date: date ?? this.date,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.index,
      'date': date.toIso8601String(),
      'severity': severity,
      'notes': notes,
    };
  }

  factory Symptom.fromMap(Map<String, dynamic> map) {
    return Symptom(
      id: map['id'] as String,
      type: SymptomType.values[map['type'] as int],
      date: DateTime.parse(map['date'] as String),
      severity: map['severity'] as int? ?? 1,
      notes: map['notes'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Symptom.fromJson(String source) =>
      Symptom.fromMap(json.decode(source) as Map<String, dynamic>);

  String get displayName {
    switch (type) {
      case SymptomType.cramps:
        return 'Cramps';
      case SymptomType.headache:
        return 'Headache';
      case SymptomType.bloating:
        return 'Bloating';
      case SymptomType.breastTenderness:
        return 'Breast Tenderness';
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.acne:
        return 'Acne';
      case SymptomType.backache:
        return 'Backache';
      case SymptomType.moodSwings:
        return 'Mood Swings';
      case SymptomType.nausea:
        return 'Nausea';
      case SymptomType.heavyFlow:
        return 'Heavy Flow';
      case SymptomType.lightFlow:
        return 'Light Flow';
      case SymptomType.spotting:
        return 'Spotting';
      case SymptomType.none:
        return 'None';
    }
  }
}
