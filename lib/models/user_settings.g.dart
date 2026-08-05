// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 5;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      averageCycleLength: fields[0] as double,
      averagePeriodDuration: fields[1] as double,
      notificationsEnabled: fields[2] as bool,
      periodReminderTime: fields[3] as String,
      ovulationReminderTime: fields[4] as String,
      cycleLengthVariation: fields[5] as double,
      isPregnancyMode: fields[6] as bool,
      pregnancyDueDate: fields[7] as DateTime?,
      preferredWeekStartDay: fields[8] as String,
      anonymousMode: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.averageCycleLength)
      ..writeByte(1)
      ..write(obj.averagePeriodDuration)
      ..writeByte(2)
      ..write(obj.notificationsEnabled)
      ..writeByte(3)
      ..write(obj.periodReminderTime)
      ..writeByte(4)
      ..write(obj.ovulationReminderTime)
      ..writeByte(5)
      ..write(obj.cycleLengthVariation)
      ..writeByte(6)
      ..write(obj.isPregnancyMode)
      ..writeByte(7)
      ..write(obj.pregnancyDueDate)
      ..writeByte(8)
      ..write(obj.preferredWeekStartDay)
      ..writeByte(9)
      ..write(obj.anonymousMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
