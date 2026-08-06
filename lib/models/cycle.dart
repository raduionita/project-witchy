import 'package:freezed_annotation/freezed_annotation.dart';

part 'cycle.freezed.dart';
part 'cycle.g.dart';

/// A single menstrual cycle spanning from one period start to the next.
@freezed
abstract class Cycle with _$Cycle {
  const factory Cycle({
    required String id,
    required DateTime startDate,
    DateTime? endDate,
    int? length,
    String? notes,
  }) = _Cycle;

  factory Cycle.fromJson(Map<String, dynamic> json) => _$CycleFromJson(json);
}