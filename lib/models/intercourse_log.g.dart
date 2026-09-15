// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'intercourse_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IntercourseLogImpl _$$IntercourseLogImplFromJson(Map<String, dynamic> json) =>
    _$IntercourseLogImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$IntercourseLogImplToJson(
  _$IntercourseLogImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date.toIso8601String(),
  'notes': instance.notes,
};
