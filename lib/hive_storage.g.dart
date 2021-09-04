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
      breath: fields[2] as int,
    )..end = fields[1] as DateTime;
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.start)
      ..writeByte(1)
      ..write(obj.end)
      ..writeByte(2)
      ..write(obj.breath);
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
      breath: fields[1] as int,
      vibrateDuration: fields[2] as int,
      vibrateBreath: fields[3] as int,
      speakDuration: fields[4] as bool,
      speakBreath: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Preference obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.duration)
      ..writeByte(1)
      ..write(obj.breath)
      ..writeByte(2)
      ..write(obj.vibrateDuration)
      ..writeByte(3)
      ..write(obj.vibrateBreath)
      ..writeByte(4)
      ..write(obj.speakDuration)
      ..writeByte(5)
      ..write(obj.speakBreath);
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
