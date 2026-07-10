import 'package:flutter/material.dart';
import '../services/preferences_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  // il tema resta ThemeMode.system come valore di partenza
  Future<void> loadSavedTheme() async {
    _themeMode = await PreferencesService.loadThemeMode();
    notifyListeners();
  }

  void toggleTheme() {
    setTheme(_themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
  }

  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();

    // la scelta persiste dopo la chiusura dell'app.
    PreferencesService.saveThemeMode(mode);
  }
}
