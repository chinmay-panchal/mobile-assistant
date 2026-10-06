import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/workspace/constants/workspace_theme.dart';

/// Central theme provider managing ThemeMode across Papervisor.
/// Persists user preference (Light / Dark) using SharedPreferences,
/// and coordinates dynamic token changes in WorkspaceTheme.
class ThemeProvider extends ChangeNotifier {
  static const String _prefKey = 'papervisor_theme_mode';
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider() {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  bool isDarkMode(BuildContext context) {
    return _themeMode == ThemeMode.dark;
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final modeStr = prefs.getString(_prefKey);
      if (modeStr == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
      _syncThemeConstants();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final targetMode = (mode == ThemeMode.dark)
        ? ThemeMode.dark
        : ThemeMode.light;
    if (_themeMode == targetMode) return;
    _themeMode = targetMode;
    _syncThemeConstants();
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefKey,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {}
  }

  void _syncThemeConstants() {
    final dark = _themeMode == ThemeMode.dark;
    WorkspaceTheme.isDark = dark;
  }
}
