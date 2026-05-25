import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/exercise_catalog.dart';
import 'models/user_settings.dart';
import 'models/feedback_entry.dart';
import 'models/exercise_settings.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('nl', null);
  await loadExerciseCatalog();
  await Hive.initFlutter();
  Hive.registerAdapter(UserSettingsAdapter());
  Hive.registerAdapter(FeedbackEntryAdapter());
  Hive.registerAdapter(ExerciseSettingsAdapter());
  await Hive.openBox<UserSettings>('settings');
  await Hive.openBox<FeedbackEntry>('feedback');
  runApp(const ProviderScope(child: App()));
}
