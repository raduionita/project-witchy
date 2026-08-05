// Models for Witchy Period Tracker

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert' as json;

part 'models.freezed.dart';
part 'models.g.dart';

import 'package:uuid/uuid.dart' as uuid;

/// Cycle phase representing a specific menstrual cycle
@freezed
class CyclePhase with _$CyclePhase {
  const factory CyclePhase({
    required String name,
    required String description,
    required Duration durationDays,
  }) = _CyclePhase;

  static List<CyclePhase> all() => [
    CyclePhase(
      name: 'Premenstrual',
      description: 'Days before your period starts',
      durationDays: Duration(days: 7),
    ),
    CyclePhase(
      name: 'Menstruation',
      description: 'Your period flow days',
      durationDays: Duration(days: 5),
    ),
    CyclePhase(
      name: 'Follicular',
      description: 'Pre-ovulatory phase, building follicles',
      durationDays: Duration(days: 10),
    ),
    CyclePhase(
      name: 'Ovulation',
      description: 'Release of egg, highly fertile',
      durationDays: Duration(days: 1),
    ),
    CyclePhase(
      name: 'Luteal',
      description: 'Post-ovulation, preparing uterus for implantation',
      durationDays: Duration(days: 14),
    ),
  ];

  bool isFertile() => name == 'Ovulation' || name == 'Luteal';
}

/// Represents a single cycle entry (period, ovulation, etc.)
@freezed
class CycleEntry with _$CycleEntry {
  const factory CycleEntry({
    required String id,
    required DateTime date,
    required EntryType type,
    required Duration durationDays,
    String? symptoms,
  }) = _CycleEntry;

  factory CycleEntry.fromJson(Map<String, dynamic> json) =>
      $CycleEntryFromJson(json);

  Map<String, dynamic> toJson() => _$CycleEntryToJson(this);

  static String uniqueId() => uuid.Uuid().v4();

  bool isPeriodStart() => type == EntryType.periodStart;
  bool isPeriodEnd() => type == EntryType.periodEnd;
  bool isOvulation() => type == EntryType.ovulation;

  DateTime get endDate => date.add(Duration(days: durationDays.inDays));
}

/// Entry types that can be tracked
enum EntryType {
  periodStart,
  periodEnd,
  ovulation,
  pregnancyTest,
  other,
}

/// Pregnancy information model
@freezed
class PregnancyInfo with _$PregnancyInfo {
  const factory PregnancyInfo({
    required DateTime dueDate,
    required DateTime lastMenstrualPeriod,
    required int currentWeek,
    bool? confirmed,
  }) = _PregnancyInfo;

  factory PregnancyInfo.fromJson(Map<String, dynamic> json) =>
      $PregnancyInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PregnancyInfoToJson(this);

  Duration get daysUntilDue => dueDate.difference(DateTime.now());
  
  bool isDueSoon() {
    if (daysUntilDue.inDays < 7) return true;
    if (dueDate.isBefore(DateTime.now())) return false; // Already overdue
    return false;
  }

  String get trimester {
    if (currentWeek <= 12) return 'First';
    if (currentWeek <= 26) return 'Second';
    return 'Third';
  }
}

/// Perimenopause tracking model
@freezed
class PerimenopauseTracker with _$PerimenopauseTracker {
  const factory PerimenopauseTracker({
    required int age,
    required List<Symptom> symptoms,
    DateTime? lastPeriodDate,
  }) = _PerimenopauseTracker;

  factory PerimenopauseTracker.fromJson(Map<String, dynamic> json) =>
      $PerimenopauseTrackerFromJson(json);

  Map<String, dynamic> toJson() => _$PerimenopauseTrackerToJson(this);
}

/// A symptom that can be tracked in perimenopause or cycles
@freezed
class Symptom with _$Symptom {
  const factory Symptom({
    required String name,
    required double intensity,
    DateTime? timestamp,
  }) = _Symptom;

  factory Symptom.fromJson(Map<String, dynamic> json) =>
      $SymptomFromJson(json);

  Map<String, dynamic> toJson() => _$SymptomToJson(this);
}

/// Health insights and predictions for the current cycle
@freezed
class CyclePrediction with _$CyclePrediction {
  const factory CyclePrediction({
    required int? nextPeriodStart,
    required int? nextOvulation,
    required List<String> fertileDays,
    bool isFertileNow,
  }) = _CyclePrediction;

  factory CyclePrediction.fromJson(Map<String, dynamic> json) =>
      $CyclePredictionFromJson(json);

  Map<String, dynamic> toJson() => _$CyclePredictionToJson(this);
}

/// Summary data for the current month's tracking
@freezed
class MonthlySummary with _$MonthlySummary {
  const factory MonthlySummary({
    required int averageCycleLength,
    required int shortestCycle,
    required int longestCycle,
    double? averageLength,
    bool isRegular,
  }) = _MonthlySummary;

  factory MonthlySummary.fromJson(Map<String, dynamic> json) =>
      $MonthlySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlySummaryToJson(this);
}
