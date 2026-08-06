import 'dart:convert';

class FertilityPrediction {
  final String id;
  final DateTime cycleStartDate;
  final int cycleLength;
  final DateTime? ovulationDate;
  final DateTime? fertileWindowStart;
  final DateTime? fertileWindowEnd;
  final double fertilityScore;
  final List<FertilityDay> fertilityDays;

  const FertilityPrediction({
    required this.id,
    required this.cycleStartDate,
    this.cycleLength = 28,
    this.ovulationDate,
    this.fertileWindowStart,
    this.fertileWindowEnd,
    this.fertilityScore = 0.0,
    this.fertilityDays = const [],
  });

  FertilityPrediction copyWith({
    String? id,
    DateTime? cycleStartDate,
    int? cycleLength,
    DateTime? ovulationDate,
    DateTime? fertileWindowStart,
    DateTime? fertileWindowEnd,
    double? fertilityScore,
    List<FertilityDay>? fertilityDays,
  }) {
    return FertilityPrediction(
      id: id ?? this.id,
      cycleStartDate: cycleStartDate ?? this.cycleStartDate,
      cycleLength: cycleLength ?? this.cycleLength,
      ovulationDate: ovulationDate ?? this.ovulationDate,
      fertileWindowStart: fertileWindowStart ?? this.fertileWindowStart,
      fertileWindowEnd: fertileWindowEnd ?? this.fertileWindowEnd,
      fertilityScore: fertilityScore ?? this.fertilityScore,
      fertilityDays: fertilityDays ?? this.fertilityDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cycleStartDate': cycleStartDate.toIso8601String(),
      'cycleLength': cycleLength,
      'ovulationDate': ovulationDate?.toIso8601String(),
      'fertileWindowStart': fertileWindowStart?.toIso8601String(),
      'fertileWindowEnd': fertileWindowEnd?.toIso8601String(),
      'fertilityScore': fertilityScore,
      'fertilityDays': fertilityDays.map((day) => day.toMap()).toList(),
    };
  }

  factory FertilityPrediction.fromMap(Map<String, dynamic> map) {
    return FertilityPrediction(
      id: map['id'] as String,
      cycleStartDate: DateTime.parse(map['cycleStartDate'] as String),
      cycleLength: map['cycleLength'] as int? ?? 28,
      ovulationDate: map['ovulationDate'] != null
          ? DateTime.parse(map['ovulationDate'] as String)
          : null,
      fertileWindowStart: map['fertileWindowStart'] != null
          ? DateTime.parse(map['fertileWindowStart'] as String)
          : null,
      fertileWindowEnd: map['fertileWindowEnd'] != null
          ? DateTime.parse(map['fertileWindowEnd'] as String)
          : null,
      fertilityScore: (map['fertilityScore'] as num?)?.toDouble() ?? 0.0,
      fertilityDays: (map['fertilityDays'] as List<dynamic>?)
              ?.map((day) => FertilityDay.fromMap(Map<String, dynamic>.from(day)))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  factory FertilityPrediction.fromJson(String source) =>
      FertilityPrediction.fromMap(json.decode(source) as Map<String, dynamic>);
}

class FertilityDay {
  final DateTime date;
  final double fertilityScore;
  final bool isFertile;
  final bool isOvulation;

  const FertilityDay({
    required this.date,
    this.fertilityScore = 0.0,
    this.isFertile = false,
    this.isOvulation = false,
  });

  FertilityDay copyWith({
    DateTime? date,
    double? fertilityScore,
    bool? isFertile,
    bool? isOvulation,
  }) {
    return FertilityDay(
      date: date ?? this.date,
      fertilityScore: fertilityScore ?? this.fertilityScore,
      isFertile: isFertile ?? this.isFertile,
      isOvulation: isOvulation ?? this.isOvulation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'fertilityScore': fertilityScore,
      'isFertile': isFertile,
      'isOvulation': isOvulation,
    };
  }

  factory FertilityDay.fromMap(Map<String, dynamic> map) {
    return FertilityDay(
      date: DateTime.parse(map['date'] as String),
      fertilityScore: (map['fertilityScore'] as num?)?.toDouble() ?? 0.0,
      isFertile: map['isFertile'] as bool? ?? false,
      isOvulation: map['isOvulation'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory FertilityDay.fromJson(String source) =>
      FertilityDay.fromMap(json.decode(source) as Map<String, dynamic>);
}
