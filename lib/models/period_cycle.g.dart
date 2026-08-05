// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_cycle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PeriodCycleAdapter extends TypeAdapter<PeriodCycle> {
  @override
  final int typeId = 0;

  @override
  PeriodCycle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PeriodCycle(
      startDate: fields[0] as DateTime,
      endDate: fields[1] as DateTime?,
      flowIntensity: fields[2] as double,
      symptoms: (fields[3] as List?)?.cast<Symptom>(),
      notes: fields[4] as String?,
      moods: (fields[5] as List?)?.cast<MoodEntry>(),
      dischargePatterns: (fields[6] as List?)?.cast<DischargePattern>(),
    );
  }

  @override
  void write(BinaryWriter writer, PeriodCycle obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.startDate)
      ..writeByte(1)
      ..write(obj.endDate)
      ..writeByte(2)
      ..write(obj.flowIntensity)
      ..writeByte(3)
      ..write(obj.symptoms)
      ..writeByte(4)
      ..write(obj.notes)
      ..writeByte(5)
      ..write(obj.moods)
      ..writeByte(6)
      ..write(obj.dischargePatterns);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodCycleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymptomAdapter extends TypeAdapter<Symptom> {
  @override
  final int typeId = 1;

  @override
  Symptom read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Symptom(
      name: fields[0] as String,
      severity: fields[1] as double,
      timestamp: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Symptom obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.severity)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymptomAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodEntryAdapter extends TypeAdapter<MoodEntry> {
  @override
  final int typeId = 2;

  @override
  MoodEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodEntry(
      mood: fields[0] as Mood,
      timestamp: fields[1] as DateTime?,
      note: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MoodEntry obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.mood)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoodAdapter extends TypeAdapter<Mood> {
  @override
  final int typeId = 3;

  @override
  Mood read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return Mood.happy;
      case 1:
        return Mood.sad;
      case 2:
        return Mood.irritable;
      case 3:
        return Mood.anxious;
      case 4:
        return Mood.energetic;
      case 5:
        return Mood.tired;
      case 6:
        return Mood.focused;
      case 7:
        return Mood.crampy;
      case 8:
        return Mood.bloated;
      case 9:
        return Mood.nauseous;
      default:
        return Mood.happy;
    }
  }

  @override
  void write(BinaryWriter writer, Mood obj) {
    switch (obj) {
      case Mood.happy:
        writer.writeByte(0);
        break;
      case Mood.sad:
        writer.writeByte(1);
        break;
      case Mood.irritable:
        writer.writeByte(2);
        break;
      case Mood.anxious:
        writer.writeByte(3);
        break;
      case Mood.energetic:
        writer.writeByte(4);
        break;
      case Mood.tired:
        writer.writeByte(5);
        break;
      case Mood.focused:
        writer.writeByte(6);
        break;
      case Mood.crampy:
        writer.writeByte(7);
        break;
      case Mood.bloated:
        writer.writeByte(8);
        break;
      case Mood.nauseous:
        writer.writeByte(9);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DischargePatternAdapter extends TypeAdapter<DischargePattern> {
  @override
  final int typeId = 4;

  @override
  DischargePattern read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DischargePattern.dry;
      case 1:
        return DischargePattern.sticky;
      case 2:
        return DischargePattern.creamy;
      case 3:
        return DischargePattern.watery;
      case 4:
        return DischargePattern.eggWhite;
      case 5:
        return DischargePattern.abundant;
      default:
        return DischargePattern.dry;
    }
  }

  @override
  void write(BinaryWriter writer, DischargePattern obj) {
    switch (obj) {
      case DischargePattern.dry:
        writer.writeByte(0);
        break;
      case DischargePattern.sticky:
        writer.writeByte(1);
        break;
      case DischargePattern.creamy:
        writer.writeByte(2);
        break;
      case DischargePattern.watery:
        writer.writeByte(3);
        break;
      case DischargePattern.eggWhite:
        writer.writeByte(4);
        break;
      case DischargePattern.abundant:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DischargePatternAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
