import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._internal();
  static final AppSettings instance = AppSettings._internal();

  static const String _themePrefKey = 'themeMode';
  static const String _languagePrefKey = 'language';

  String? _themeModeLabel;
  String? _languageLabel;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  bool get hasSelectedTheme => _themeModeLabel != null;
  bool get hasSelectedLanguage => _languageLabel != null;

  ThemeMode get themeMode {
    switch (_themeModeLabel) {
      case 'Light':
        return ThemeMode.light;
      case 'Dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String get themeModeLabel => _themeModeLabel ?? 'System';

  String get languageLabel => _languageLabel ?? 'English';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeModeLabel = prefs.getString(_themePrefKey);
    _languageLabel = prefs.getString(_languagePrefKey);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(String label) async {
    if (label == _themeModeLabel) return;
    _themeModeLabel = label;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, label);
    notifyListeners();
  }

  Future<void> setLanguage(String label) async {
    if (label == _languageLabel) return;
    _languageLabel = label;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languagePrefKey, label);
    notifyListeners();
  }
}
