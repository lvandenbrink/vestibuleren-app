import 'package:hive/hive.dart';

part 'exercise_settings.g.dart';

@HiveType(typeId: 2)
class ExerciseSettings {
  @HiveField(0)
  int bpm;

  @HiveField(1)
  int reps;

  @HiveField(2)
  int sets;

  @HiveField(3)
  int restSeconds;

  ExerciseSettings({
    this.bpm = 60,
    this.reps = 30,
    this.sets = 1,
    this.restSeconds = 30,
  });

  ExerciseSettings copyWith({
    int? bpm,
    int? reps,
    int? sets,
    int? restSeconds,
  }) =>
      ExerciseSettings(
        bpm: bpm ?? this.bpm,
        reps: reps ?? this.reps,
        sets: sets ?? this.sets,
        restSeconds: restSeconds ?? this.restSeconds,
      );
}
