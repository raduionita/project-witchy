import 'dart:convert';

class PeriodCycle {
  final String id;
  final DateTime startDate;
  final DateTime? endDate;
  final int cycleLength;
  final List<PeriodDay> days;
  final DateTime? lastPeriodStart;
  final DateTime? nextPeriodEstimate;
  final DateTime? ovulationDate;
  final double cycleLengthDays;

  const PeriodCycle({
    required this.id,
    required this.startDate,
    this.endDate,
    this.cycleLength = 28,
    this.days = const [],
    this.lastPeriodStart,
    this.nextPeriodEstimate,
    this.ovulationDate,
    this.cycleLengthDays = 28.0,
  });

  PeriodCycle copyWith({
    String? id,
    DateTime? startDate,
    DateTime? endDate,
    int? cycleLength,
    List<PeriodDay>? days,
    DateTime? lastPeriodStart,
    DateTime? nextPeriodEstimate,
    DateTime? ovulationDate,
    double? cycleLengthDays,
  }) {
    return PeriodCycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      cycleLength: cycleLength ?? this.cycleLength,
      days: days ?? this.days,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      nextPeriodEstimate: nextPeriodEstimate ?? this.nextPeriodEstimate,
      ovulationDate: ovulationDate ?? this.ovulationDate,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'cycleLength': cycleLength,
      'days': days.map((day) => day.toMap()).toList(),
      'lastPeriodStart': lastPeriodStart?.toIso8601String(),
      'nextPeriodEstimate': nextPeriodEstimate?.toIso8601String(),
      'ovulationDate': ovulationDate?.toIso8601String(),
      'cycleLengthDays': cycleLengthDays,
    };
  }

  factory PeriodCycle.fromMap(Map<String, dynamic> map) {
    return PeriodCycle(
      id: map['id'] as String,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate'] as String) : null,
      cycleLength: map['cycleLength'] as int? ?? 28,
      days: (map['days'] as List<dynamic>?)
              ?.map((day) => PeriodDay.fromMap(Map<String, dynamic>.from(day)))
              .toList() ??
          [],
      lastPeriodStart: map['lastPeriodStart'] != null
          ? DateTime.parse(map['lastPeriodStart'] as String)
          : null,
      nextPeriodEstimate: map['nextPeriodEstimate'] != null
          ? DateTime.parse(map['nextPeriodEstimate'] as String)
          : null,
      ovulationDate: map['ovulationDate'] != null
          ? DateTime.parse(map['ovulationDate'] as String)
          : null,
      cycleLengthDays: (map['cycleLengthDays'] as num?)?.toDouble() ?? 28.0,
    );
  }

  String toJson() => json.encode(toMap());

  factory PeriodCycle.fromJson(String source) =>
      PeriodCycle.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'PeriodCycle(id: $id, startDate: $startDate, cycleLength: $cycleLength)';
}

class PeriodDay {
  final DateTime date;
  final int flowLevel;
  final List<String> symptoms;
  final String? notes;
  final double? temperature;

  const PeriodDay({
    required this.date,
    this.flowLevel = 0,
    this.symptoms = const [],
    this.notes,
    this.temperature,
  });

  PeriodDay copyWith({
    DateTime? date,
    int? flowLevel,
    List<String>? symptoms,
    String? notes,
    double? temperature,
  }) {
    return PeriodDay(
      date: date ?? this.date,
      flowLevel: flowLevel ?? this.flowLevel,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      temperature: temperature ?? this.temperature,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'flowLevel': flowLevel,
      'symptoms': symptoms,
      'notes': notes,
      'temperature': temperature,
    };
  }

  factory PeriodDay.fromMap(Map<String, dynamic> map) {
    return PeriodDay(
      date: DateTime.parse(map['date'] as String),
      flowLevel: map['flowLevel'] as int? ?? 0,
      symptoms: (map['symptoms'] as List<dynamic>?)?.cast<String>() ?? [],
      notes: map['notes'] as String?,
      temperature: (map['temperature'] as num?)?.toDouble(),
    );
  }

  String toJson() => json.encode(toMap());

  factory PeriodDay.fromJson(String source) =>
      PeriodDay.fromMap(json.decode(source) as Map<String, dynamic>);
}
