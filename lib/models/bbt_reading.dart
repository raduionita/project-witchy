import 'package:freezed_annotation/freezed_annotation.dart';

import 'time_of_day_model.dart';

part 'bbt_reading.freezed.dart';
part 'bbt_reading.g.dart';

/// A single basal body temperature reading for a day.
@freezed
abstract class BbtReading with _$BbtReading {
  const factory BbtReading({
    required String id,
    required DateTime date,
    required double tempC,
    TimeOfDayModel? takenAt,
    String? notes,
  }) = _BbtReading;

  factory BbtReading.fromJson(Map<String, dynamic> json) =>
      _$BbtReadingFromJson(json);
}
