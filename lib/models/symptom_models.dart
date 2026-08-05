// Symptom tracking model and related enums

import 'package:freezed_annotation/freezed_annotation.dart';
import '../utils/constants.dart';

part 'symptom_models.freezed.dart';
part 'symptom_models.g.dart';

/// Represents a symptom that can be tracked during a cycle
@freezed
class TrackedSymptom with _$TrackedSymptom {
  const factory TrackedSymptom({
    required String id,
    required DateTime date,
    required String symptomName,
    required double intensity, // 1-10 scale
    DateTime? timestamp,
    String? notes,
  }) = _TrackedSymptom;

  factory TrackedSymptom.fromJson(Map<String, dynamic> json) =>
      $TrackedSymptomFromJson(json);

  Map<String, dynamic> toJson() => _$TrackedSymptomToJson(this);
}

/// All available symptom types for tracking
enum SymptomType {
  cramps,
  bloating,
  breastTenderness,
  moodChanges,
  fatigue,
  headaches,
  sleepIssues,
  nausea,
  dizziness,
  skinChanges,
  backPain,
  jointPain,
}

/// Symptom label and icon for UI display
enum SymptomDisplay {
  cramps('Cramps', 'cramping'),
  bloating('Bloating', 'cloud_rain'),
  breastTenderness('Breast Tenderness', 'checkup'),
  moodChanges('Mood Changes', 'emotional'),
  fatigue('Fatigue', 'sleeping'),
  headaches('Headaches', 'headset'),
  sleepIssues('Sleep Issues', 'sleeping'),
  nausea('Nausea', 'wrenching'),
  dizziness('Dizziness', 'auto_aviation'),
  skinChanges('Skin Changes', 'spa'),
  backPain('Back Pain', 'checkup'),
  jointPain('Joint Pain', 'checkup');

  final String label;
  final String iconName;

  const SymptomDisplay({required this.label, required this.iconName});
}

/// Summary of symptoms for a specific date
@freezed
class DailySymptomSummary with _$DailySymptomSummary {
  const factory DailySymptomSummary({
    required DateTime date,
    required List<String> symptomIds,
    required double averageIntensity,
    int? totalSymptoms,
  }) = _DailySymptomSummary;

  factory DailySymptomSummary.fromJson(Map<String, dynamic> json) =>
      $DailySymptomSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$DailySymptomSummaryToJson(this);
}
