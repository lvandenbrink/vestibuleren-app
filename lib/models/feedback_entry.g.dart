// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedbackEntryAdapter extends TypeAdapter<FeedbackEntry> {
  @override
  final int typeId = 1;

  @override
  FeedbackEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedbackEntry(
      exerciseId: fields[0] as String,
      completedAt: fields[1] as DateTime,
      rating: fields[2] as int?,
      painLevel: fields[3] as int?,
      madeItWorse: fields[4] as bool?,
      notes: fields[5] as String?,
      bpm: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, FeedbackEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.exerciseId)
      ..writeByte(1)
      ..write(obj.completedAt)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.painLevel)
      ..writeByte(4)
      ..write(obj.madeItWorse)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.bpm);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedbackEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
