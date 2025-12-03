import 'package:flutter/material.dart';
import 'app_colors.dart';

class ThemeNotifier extends ChangeNotifier {
  AppTheme _currentTheme = AppColors.pinkTheme;
  bool _isDarkMode = false;

  AppTheme get theme => _currentTheme;
  bool get isDarkMode => _isDarkMode;

  AppColorPalette get currentPalette => _isDarkMode ? _currentTheme.dark : _currentTheme.light;

  void setTheme(AppTheme newTheme) {
    _currentTheme = newTheme;
    notifyListeners();
  }

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}
