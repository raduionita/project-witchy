// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PeriodLogImpl _$$PeriodLogImplFromJson(Map<String, dynamic> json) =>
    _$PeriodLogImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      intensity: $enumDecodeNullable(_$FlowIntensityEnumMap, json['intensity']),
      symptoms:
          (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      mood: json['mood'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$PeriodLogImplToJson(_$PeriodLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'intensity': _$FlowIntensityEnumMap[instance.intensity],
      'symptoms': instance.symptoms,
      'mood': instance.mood,
      'notes': instance.notes,
    };

const _$FlowIntensityEnumMap = {
  FlowIntensity.light: 'light',
  FlowIntensity.medium: 'medium',
  FlowIntensity.heavy: 'heavy',
};
