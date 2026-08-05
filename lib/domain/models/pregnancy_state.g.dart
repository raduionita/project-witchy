// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pregnancy_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PregnancyStateAdapter extends TypeAdapter<PregnancyState> {
  @override
  final int typeId = 2;

  @override
  PregnancyState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PregnancyState(
      id: fields[0] as String,
      conceptionDate: fields[1] as DateTime,
      isCurrent: fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PregnancyState obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conceptionDate)
      ..writeByte(2)
      ..write(obj.isCurrent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PregnancyStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PregnancyStateImpl _$$PregnancyStateImplFromJson(Map<String, dynamic> json) =>
    _$PregnancyStateImpl(
      id: json['id'] as String,
      conceptionDate: DateTime.parse(json['conceptionDate'] as String),
      isCurrent: json['isCurrent'] as bool? ?? false,
    );

Map<String, dynamic> _$$PregnancyStateImplToJson(
        _$PregnancyStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conceptionDate': instance.conceptionDate.toIso8601String(),
      'isCurrent': instance.isCurrent,
    };
