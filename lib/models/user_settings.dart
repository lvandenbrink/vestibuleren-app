import 'package:hive/hive.dart';
import 'exercise_settings.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 0)
class UserSettings extends HiveObject {
  @HiveField(0)
  List<String> selectedExerciseIds;

  @HiveField(2)
  bool onboardingComplete;

  @HiveField(3)
  String physioEmail;

  @HiveField(6)
  DateTime? lastSessionDate;

  /// Per-exercise settings (bpm, reps, sets, rest). Replaces the old
  /// separate exerciseBpms / exerciseReps / exerciseSets / exerciseRestSeconds maps.
  @HiveField(10)
  Map<String, ExerciseSettings> exerciseSettings;

  UserSettings({
    required this.selectedExerciseIds,
    required this.onboardingComplete,
    required this.physioEmail,
    this.lastSessionDate,
    Map<String, ExerciseSettings>? exerciseSettings,
  }) : exerciseSettings = exerciseSettings ?? {};

  factory UserSettings.defaults() => UserSettings(
        selectedExerciseIds: [],
        onboardingComplete: false,
        physioEmail: '',
        lastSessionDate: null,
        exerciseSettings: {},
      );
}
