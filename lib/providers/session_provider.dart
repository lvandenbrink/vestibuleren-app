import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/exercise_catalog.dart';
import '../models/exercise.dart';
import 'feedback_provider.dart';
import 'settings_provider.dart';

class SessionItem {
  final Exercise exercise;
  bool completed;

  SessionItem({required this.exercise, this.completed = false});
}

class SessionState {
  final List<SessionItem> items;
  final int currentIndex;

  const SessionState({
    required this.items,
    required this.currentIndex,
  });

  bool get isComplete => items.every((item) => item.completed);

  SessionItem? get current =>
      currentIndex < items.length ? items[currentIndex] : null;
}

final sessionProvider =
    NotifierProvider<SessionNotifier, SessionState>(() => SessionNotifier());

class SessionNotifier extends Notifier<SessionState> {
  @override
  SessionState build() {
    final settings = ref.watch(settingsProvider);
    final feedbackEntries = ref.watch(feedbackProvider);

    final today = DateTime.now();
    final completedTodayIds = feedbackEntries
        .where((e) =>
            e.completedAt.year == today.year &&
            e.completedAt.month == today.month &&
            e.completedAt.day == today.day)
        .map((e) => e.exerciseId)
        .toSet();

    final exercises = settings.selectedExerciseIds
        .map((id) => exerciseCatalog.where((e) => e.id == id).firstOrNull)
        .whereType<Exercise>()
        .map((e) => SessionItem(
              exercise: e,
              completed: completedTodayIds.contains(e.id),
            ))
        .toList();

    final firstUncompleted = exercises.indexWhere((item) => !item.completed);
    final currentIndex =
        firstUncompleted == -1 ? exercises.length : firstUncompleted;

    return SessionState(items: exercises, currentIndex: currentIndex);
  }
}
