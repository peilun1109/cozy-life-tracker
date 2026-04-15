import 'dart:convert';

import '../models/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _settingsKey = 'app_settings_json';

  Future<AppSettings> fetchSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_settingsKey);
    if (raw == null || raw.isEmpty) {
      final defaults = AppSettings.defaults();
      await updateSettings(defaults);
      return defaults;
    }
    return AppSettings.fromMap(
      Map<String, Object?>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> updateSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(settings.toMap()));
  }
}
