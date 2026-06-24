import 'package:flutter/material.dart';

import '../services/theme_storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider({ThemeStorageService? storage})
      : _storage = storage ?? ThemeStorageService();

  final ThemeStorageService _storage;

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> load() async {
    _themeMode = await _storage.loadThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      await _storage.saveThemeMode(mode);
    } catch (_) {
      // Preference not saved; theme still applies for this session.
    }
  }

  Future<void> toggleTheme() async {
    final next = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(next);
  }
}
