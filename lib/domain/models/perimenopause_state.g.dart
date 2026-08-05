// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'perimenopause_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PerimenopauseStateAdapter extends TypeAdapter<PerimenopauseState> {
  @override
  final int typeId = 3;

  @override
  PerimenopauseState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PerimenopauseState(
      id: fields[0] as String,
      isTracking: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PerimenopauseState obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isTracking);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PerimenopauseStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PerimenopauseStateImpl _$$PerimenopauseStateImplFromJson(
        Map<String, dynamic> json) =>
    _$PerimenopauseStateImpl(
      id: json['id'] as String,
      isTracking: json['isTracking'] as bool? ?? false,
    );

Map<String, dynamic> _$$PerimenopauseStateImplToJson(
        _$PerimenopauseStateImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'isTracking': instance.isTracking,
    };
