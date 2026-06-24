import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constants/app_constants.dart';
import 'hive_service.dart';

class ThemeStorageService {
  static const _themeModeKey = 'theme_mode';

  Future<ThemeMode> loadThemeMode() async {
    try {
      await HiveService.init();
      final box = await Hive.openBox<String>(AppConstants.settingsBoxName);
      final value = box.get(_themeModeKey);

      return switch (value) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.system,
      };
    } catch (_) {
      return ThemeMode.system;
    }
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final box = await Hive.openBox<String>(AppConstants.settingsBoxName);
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await box.put(_themeModeKey, value);
  }
}
