import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum UniBuddyThemeMode { system, light, dark }

class ThemeController extends ChangeNotifier {
  static const _key = 'unibuddy_theme_mode_v1';
  UniBuddyThemeMode mode = UniBuddyThemeMode.system;
  bool _ready = false;

  bool get ready => _ready;

  ThemeMode get themeMode {
    switch (mode) {
      case UniBuddyThemeMode.light:
        return ThemeMode.light;
      case UniBuddyThemeMode.dark:
        return ThemeMode.dark;
      case UniBuddyThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> load() async {
    if (_ready) return;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    mode = UniBuddyThemeMode.values.firstWhere(
      (item) => item.name == value,
      orElse: () => UniBuddyThemeMode.system,
    );
    _ready = true;
    notifyListeners();
  }

  Future<void> setMode(UniBuddyThemeMode value) async {
    mode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, value.name);
  }
}

final themeController = ThemeController();
