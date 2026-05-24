// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 0;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      selectedExerciseIds: (fields[0] as List?)?.cast<String>() ?? [],
      onboardingComplete: fields[2] as bool? ?? false,
      physioEmail: fields[3] as String? ?? '',
      lastSessionDate: fields[6] as DateTime?,
      exerciseSettings:
          (fields[10] as Map?)?.cast<String, ExerciseSettings>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.selectedExerciseIds)
      ..writeByte(2)
      ..write(obj.onboardingComplete)
      ..writeByte(3)
      ..write(obj.physioEmail)
      ..writeByte(6)
      ..write(obj.lastSessionDate)
      ..writeByte(10)
      ..write(obj.exerciseSettings);
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
