import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/settings_repository.dart';
import '../models/exercise_settings.dart';
import '../models/user_settings.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider = NotifierProvider<SettingsNotifier, UserSettings>(() {
  return SettingsNotifier();
});

class SettingsNotifier extends Notifier<UserSettings> {
  @override
  UserSettings build() {
    return ref.read(settingsRepositoryProvider).load();
  }

  ExerciseSettings settingsFor(String exerciseId) {
    return state.exerciseSettings[exerciseId] ?? ExerciseSettings();
  }

  Future<void> completeOnboarding({
    required List<String> selectedIds,
  }) async {
    state = UserSettings(
      selectedExerciseIds: selectedIds,
      onboardingComplete: true,
      physioEmail: state.physioEmail,
      exerciseSettings: state.exerciseSettings,
      lastSessionDate: state.lastSessionDate,
    );
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> updateExerciseSelection(List<String> ids) async {
    state = UserSettings(
      selectedExerciseIds: ids,
      onboardingComplete: state.onboardingComplete,
      physioEmail: state.physioEmail,
      exerciseSettings: state.exerciseSettings,
      lastSessionDate: state.lastSessionDate,
    );
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> updateExerciseSettings(
      String exerciseId, ExerciseSettings settings) async {
    final map =
        Map<String, ExerciseSettings>.from(state.exerciseSettings);
    map[exerciseId] = settings;
    state = UserSettings(
      selectedExerciseIds: state.selectedExerciseIds,
      onboardingComplete: state.onboardingComplete,
      physioEmail: state.physioEmail,
      exerciseSettings: map,
      lastSessionDate: state.lastSessionDate,
    );
    await ref.read(settingsRepositoryProvider).save(state);
  }

  Future<void> updateExerciseBpm(String id, int bpm) async {
    await updateExerciseSettings(
        id, settingsFor(id).copyWith(bpm: bpm.clamp(0, 250)));
  }

  Future<void> updateExerciseReps(String id, int reps) async {
    await updateExerciseSettings(
        id, settingsFor(id).copyWith(reps: reps.clamp(5, 300)));
  }

  Future<void> updateExerciseSets(String id, int sets) async {
    await updateExerciseSettings(
        id, settingsFor(id).copyWith(sets: sets.clamp(1, 20)));
  }

  Future<void> updateExerciseRestSeconds(String id, int seconds) async {
    await updateExerciseSettings(
        id, settingsFor(id).copyWith(restSeconds: seconds.clamp(0, 120)));
  }

  Future<void> markSessionComplete() async {
    state = UserSettings(
      selectedExerciseIds: state.selectedExerciseIds,
      onboardingComplete: state.onboardingComplete,
      physioEmail: state.physioEmail,
      exerciseSettings: state.exerciseSettings,
      lastSessionDate: DateTime.now(),
    );
    await ref.read(settingsRepositoryProvider).save(state);
  }
}
