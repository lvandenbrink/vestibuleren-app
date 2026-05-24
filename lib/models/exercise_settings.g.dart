// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseSettingsAdapter extends TypeAdapter<ExerciseSettings> {
  @override
  final int typeId = 2;

  @override
  ExerciseSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSettings(
      bpm: (fields[0] as int?) ?? 0,
      reps: (fields[1] as int?) ?? 30,
      sets: (fields[2] as int?) ?? 1,
      restSeconds: (fields[3] as int?) ?? 30,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.bpm)
      ..writeByte(1)
      ..write(obj.reps)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.restSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
