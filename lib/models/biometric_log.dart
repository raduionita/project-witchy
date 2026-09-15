import 'package:freezed_annotation/freezed_annotation.dart';

import 'bbt_reading.dart';
import 'cervical_mucus_type.dart';
import 'intercourse_log.dart';
import 'ovulation_test_result.dart';
import 'pregnancy_test_result.dart';

part 'biometric_log.freezed.dart';
part 'biometric_log.g.dart';

/// Per-day aggregate of fertility & biometric observations.
///
/// Combines a [BbtReading], cervical [mucus] type, LH [ovulationTest] and
/// [pregnancyTest] results, and an optional [intercourse] record into a single
/// daily entry so the calendar and charts can query one row per date.
@freezed
abstract class BiometricLog with _$BiometricLog {
  const factory BiometricLog({
    required String id,
    required DateTime date,
    BbtReading? bbt,
    CervicalMucusType? mucus,
    OvulationTestResult? ovulationTest,
    PregnancyTestResult? pregnancyTest,
    IntercourseLog? intercourse,
  }) = _BiometricLog;

  factory BiometricLog.fromJson(Map<String, dynamic> json) =>
      _$BiometricLogFromJson(json);
}
