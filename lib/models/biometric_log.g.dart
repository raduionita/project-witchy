// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'biometric_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BiometricLogImpl _$$BiometricLogImplFromJson(Map<String, dynamic> json) =>
    _$BiometricLogImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      bbt:
          json['bbt'] == null
              ? null
              : BbtReading.fromJson(json['bbt'] as Map<String, dynamic>),
      mucus: $enumDecodeNullable(_$CervicalMucusTypeEnumMap, json['mucus']),
      ovulationTest: $enumDecodeNullable(
        _$OvulationTestResultEnumMap,
        json['ovulationTest'],
      ),
      pregnancyTest: $enumDecodeNullable(
        _$PregnancyTestResultEnumMap,
        json['pregnancyTest'],
      ),
      intercourse:
          json['intercourse'] == null
              ? null
              : IntercourseLog.fromJson(
                json['intercourse'] as Map<String, dynamic>,
              ),
    );

Map<String, dynamic> _$$BiometricLogImplToJson(_$BiometricLogImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'bbt': instance.bbt?.toJson(),
      'mucus': _$CervicalMucusTypeEnumMap[instance.mucus],
      'ovulationTest': _$OvulationTestResultEnumMap[instance.ovulationTest],
      'pregnancyTest': _$PregnancyTestResultEnumMap[instance.pregnancyTest],
      'intercourse': instance.intercourse?.toJson(),
    };

const _$CervicalMucusTypeEnumMap = {
  CervicalMucusType.dry: 'dry',
  CervicalMucusType.sticky: 'sticky',
  CervicalMucusType.creamy: 'creamy',
  CervicalMucusType.watery: 'watery',
  CervicalMucusType.eggwhite: 'eggwhite',
};

const _$OvulationTestResultEnumMap = {
  OvulationTestResult.negative: 'negative',
  OvulationTestResult.high: 'high',
  OvulationTestResult.peak: 'peak',
};

const _$PregnancyTestResultEnumMap = {
  PregnancyTestResult.negative: 'negative',
  PregnancyTestResult.positive: 'positive',
};
