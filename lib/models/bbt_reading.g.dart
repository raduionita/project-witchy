// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bbt_reading.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BbtReadingImpl _$$BbtReadingImplFromJson(Map<String, dynamic> json) =>
    _$BbtReadingImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      tempC: (json['tempC'] as num).toDouble(),
      takenAt:
          json['takenAt'] == null
              ? null
              : TimeOfDayModel.fromJson(
                json['takenAt'] as Map<String, dynamic>,
              ),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$BbtReadingImplToJson(_$BbtReadingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'tempC': instance.tempC,
      'takenAt': instance.takenAt?.toJson(),
      'notes': instance.notes,
    };
