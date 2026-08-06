// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'symptom_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SymptomLogImpl _$$SymptomLogImplFromJson(Map<String, dynamic> json) =>
    _$SymptomLogImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      symptoms:
          (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      mood: json['mood'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$SymptomLogImplToJson(_$SymptomLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'symptoms': instance.symptoms,
      'mood': instance.mood,
      'notes': instance.notes,
    };
