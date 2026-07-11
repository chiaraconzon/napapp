import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

// Manages app theme state and notifies widgets when it changes
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system; // Default theme follows system settings

  ThemeMode get themeMode => _themeMode; // Provides current theme mode to the app

  bool get isDark => _themeMode == ThemeMode.dark; // Checks if dark mode is currently active

  // Loads the saved theme preference from local storage
  Future<void> loadSavedTheme() async {
    _themeMode = await PreferencesService.loadThemeMode();
    notifyListeners();
  }

  // Switches between light and dark mode
  void toggleTheme() {
    setTheme(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  // Updates theme, notifies listeners and saves the preference
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();

    // Saves user choice for future app launches
    PreferencesService.saveThemeMode(mode);
  }
}
