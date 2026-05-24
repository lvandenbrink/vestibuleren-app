import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feedback_repository.dart';
import '../models/feedback_entry.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  return FeedbackRepository();
});

final feedbackProvider =
    NotifierProvider<FeedbackNotifier, List<FeedbackEntry>>(() {
  return FeedbackNotifier();
});

class FeedbackNotifier extends Notifier<List<FeedbackEntry>> {
  @override
  List<FeedbackEntry> build() {
    return ref.read(feedbackRepositoryProvider).loadAll();
  }

  Future<void> addEntry(FeedbackEntry entry) async {
    await ref.read(feedbackRepositoryProvider).add(entry);
    state = ref.read(feedbackRepositoryProvider).loadAll();
  }
}
