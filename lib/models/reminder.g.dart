// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReminderImpl _$$ReminderImplFromJson(Map<String, dynamic> json) =>
    _$ReminderImpl(
      id: json['id'] as String,
      type: $enumDecode(_$ReminderTypeEnumMap, json['type']),
      title: json['title'] as String,
      time: TimeOfDayModel.fromJson(json['time'] as Map<String, dynamic>),
      weekday:
          (json['weekday'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      enabled: json['enabled'] as bool? ?? true,
      body: json['body'] as String?,
    );

Map<String, dynamic> _$$ReminderImplToJson(_$ReminderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ReminderTypeEnumMap[instance.type]!,
      'title': instance.title,
      'time': instance.time.toJson(),
      'weekday': instance.weekday,
      'enabled': instance.enabled,
      'body': instance.body,
    };

const _$ReminderTypeEnumMap = {
  ReminderType.periodStart: 'periodStart',
  ReminderType.periodEnd: 'periodEnd',
  ReminderType.medication: 'medication',
  ReminderType.water: 'water',
  ReminderType.sleep: 'sleep',
  ReminderType.custom: 'custom',
};
