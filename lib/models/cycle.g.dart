// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CycleImpl _$$CycleImplFromJson(Map<String, dynamic> json) => _$CycleImpl(
  id: json['id'] as String,
  startDate: DateTime.parse(json['startDate'] as String),
  endDate:
      json['endDate'] == null
          ? null
          : DateTime.parse(json['endDate'] as String),
  length: (json['length'] as num?)?.toInt(),
  notes: json['notes'] as String?,
);

Map<String, dynamic> _$$CycleImplToJson(_$CycleImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate?.toIso8601String(),
      'length': instance.length,
      'notes': instance.notes,
    };
