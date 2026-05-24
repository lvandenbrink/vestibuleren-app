import 'package:hive_flutter/hive_flutter.dart';
import '../models/feedback_entry.dart';

class FeedbackRepository {
  static const _boxName = 'feedback';

  Box<FeedbackEntry> get _box => Hive.box<FeedbackEntry>(_boxName);

  List<FeedbackEntry> loadAll() {
    return _box.values.toList();
  }

  Future<void> add(FeedbackEntry entry) async {
    await _box.add(entry);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}
