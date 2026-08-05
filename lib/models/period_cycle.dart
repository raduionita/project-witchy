import 'package:hive/hive.dart';

part 'period_cycle.g.dart';

@HiveType(typeId: 0)
class PeriodCycle extends HiveObject {
  @HiveField(0)
  DateTime startDate;

  @HiveField(1)
  DateTime? endDate;

  @HiveField(2)
  double flowIntensity;

  @HiveField(3)
  List<Symptom> symptoms;

  @HiveField(4)
  String? notes;

  @HiveField(5)
  List<MoodEntry> moods;

  @HiveField(6)
  List<DischargePattern> dischargePatterns;

  PeriodCycle({
    required this.startDate,
    this.endDate,
    this.flowIntensity = 0.0,
    List<Symptom>? symptoms,
    this.notes,
    List<MoodEntry>? moods,
    List<DischargePattern>? dischargePatterns,
  })  : symptoms = symptoms ?? [],
        moods = moods ?? [],
        dischargePatterns = dischargePatterns ?? [];

  int get duration => endDate != null
      ? endDate!.difference(startDate).inDays + 1
      : DateTime.now().difference(startDate).inDays + 1;

  bool get isActive => endDate == null;

  double get averageFlow => flowIntensity.clamp(0.0, 5.0);

  PeriodCycle copyWith({
    DateTime? startDate,
    DateTime? endDate,
    double? flowIntensity,
    List<Symptom>? symptoms,
    String? notes,
    List<MoodEntry>? moods,
    List<DischargePattern>? dischargePatterns,
  }) {
    return PeriodCycle(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      flowIntensity: flowIntensity ?? this.flowIntensity,
      symptoms: symptoms ?? this.symptoms,
      notes: notes ?? this.notes,
      moods: moods ?? this.moods,
      dischargePatterns: dischargePatterns ?? this.dischargePatterns,
    );
  }
}

@HiveType(typeId: 1)
class Symptom extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final double severity;

  @HiveField(2)
  final DateTime timestamp;

  Symptom({
    required this.name,
    this.severity = 1.0,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() => '$name (severity: $severity)';
}

@HiveType(typeId: 2)
class MoodEntry extends HiveObject {
  @HiveField(0)
  final Mood mood;

  @HiveField(1)
  final DateTime timestamp;

  @HiveField(2)
  String? note;

  MoodEntry({
    required this.mood,
    DateTime? timestamp,
    this.note,
  }) : timestamp = timestamp ?? DateTime.now();
}

@HiveType(typeId: 3)
enum Mood {
  @HiveField(0)
  happy,

  @HiveField(1)
  sad,

  @HiveField(2)
  irritable,

  @HiveField(3)
  anxious,

  @HiveField(4)
  energetic,

  @HiveField(5)
  tired,

  @HiveField(6)
  focused,

  @HiveField(7)
  crampy,

  @HiveField(8)
  bloated,

  @HiveField(9)
  nauseous,
}

@HiveType(typeId: 4)
enum DischargePattern {
  @HiveField(0)
  dry,

  @HiveField(1)
  sticky,

  @HiveField(2)
  creamy,

  @HiveField(3)
  watery,

  @HiveField(4)
  eggWhite,

  @HiveField(5)
  abundant,
}
