// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      id: json['id'] as String,
      averageCycleLength: (json['averageCycleLength'] as num?)?.toInt() ?? 28,
      averagePeriodLength: (json['averagePeriodLength'] as num?)?.toInt() ?? 5,
      lutealPhaseLength: (json['lutealPhaseLength'] as num?)?.toInt() ?? 14,
      firstPeriodDate:
          json['firstPeriodDate'] == null
              ? null
              : DateTime.parse(json['firstPeriodDate'] as String),
      mode:
          $enumDecodeNullable(_$TrackingModeEnumMap, json['mode']) ??
          TrackingMode.cycle,
      pregnancyLmp:
          json['pregnancyLmp'] == null
              ? null
              : DateTime.parse(json['pregnancyLmp'] as String),
      onboarded: json['onboarded'] as bool? ?? false,
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'averageCycleLength': instance.averageCycleLength,
      'averagePeriodLength': instance.averagePeriodLength,
      'lutealPhaseLength': instance.lutealPhaseLength,
      'firstPeriodDate': instance.firstPeriodDate?.toIso8601String(),
      'mode': _$TrackingModeEnumMap[instance.mode]!,
      'pregnancyLmp': instance.pregnancyLmp?.toIso8601String(),
      'onboarded': instance.onboarded,
    };

const _$TrackingModeEnumMap = {
  TrackingMode.cycle: 'cycle',
  TrackingMode.pregnancy: 'pregnancy',
  TrackingMode.perimenopause: 'perimenopause',
};
