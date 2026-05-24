import 'package:hive/hive.dart';

part 'feedback_entry.g.dart';

@HiveType(typeId: 1)
class FeedbackEntry extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  DateTime completedAt;

  @HiveField(2)
  int? rating;

  @HiveField(3)
  int? painLevel;

  @HiveField(4)
  bool? madeItWorse;

  @HiveField(5)
  String? notes;

  @HiveField(6)
  int? bpm;

  FeedbackEntry({
    required this.exerciseId,
    required this.completedAt,
    this.rating,
    this.painLevel,
    this.madeItWorse,
    this.notes,
    this.bpm,
  });
}
