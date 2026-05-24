import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';

class SettingsRepository {
  static const _boxName = 'settings';
  static const _key = 'user_settings';

  Box<UserSettings> get _box => Hive.box<UserSettings>(_boxName);

  UserSettings load() {
    return _box.get(_key) ?? UserSettings.defaults();
  }

  Future<void> save(UserSettings settings) async {
    await _box.put(_key, settings);
  }
}
