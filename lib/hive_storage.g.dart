// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_storage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 0;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      start: fields[0] as DateTime,
    )
      ..end = fields[1] as DateTime
      ..breaths = fields[2] as int
      ..heartrates = (fields[3] as List?)?.cast<double>();
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.breaths)
      ..writeByte(3)
      ..write(obj.heartrates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PreferenceAdapter extends TypeAdapter<Preference> {
  @override
  final int typeId = 1;

  @override
  Preference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Preference(
      duration: fields[0] as int,
      inhale: (fields[1] as List).cast<int>(),
      exhale: (fields[2] as List).cast<int>(),
      vibrateDuration: fields[3] as int,
      vibrateBreath: fields[4] as int,
      durationTts: fields[5] as bool,
      breathTts: fields[6] as bool,
      colors: (fields[7] as List).cast<int>(),
      name: fields[8] as String,
      audio: (fields[9] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Preference obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.duration)
      ..writeByte(1)
      ..write(obj.inhale)
      ..writeByte(2)
      ..write(obj.exhale)
      ..writeByte(3)
      ..write(obj.vibrateDuration)
      ..writeByte(4)
      ..write(obj.vibrateBreath)
      ..writeByte(5)
      ..write(obj.durationTts)
      ..writeByte(6)
      ..write(obj.breathTts)
      ..writeByte(7)
      ..write(obj.colors)
      ..writeByte(8)
      ..write(obj.name)
      ..writeByte(9)
      ..write(obj.audio);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PreferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
