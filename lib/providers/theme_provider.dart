import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gestionar temas (Guinda/Azul) y modo claro/oscuro
class ThemeProvider extends ChangeNotifier {
  // Colores definidos
  static const Color guindaColor = Color(0xFF800020);
  static const Color azulColor = Color(0xFF1976D2);

  // Estado actual
  bool _isDarkMode = false;
  bool _isGuindaTheme = true; // true = guinda, false = azul

  // Preferencias
  static const String _darkModeKey = 'dark_mode';
  static const String _themeKey = 'theme_guinda';

  ThemeProvider() {
    _loadPreferences();
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isGuindaTheme => _isGuindaTheme;
  Color get currentThemeColor => _isGuindaTheme ? guindaColor : azulColor;

  /// Cargar preferencias guardadas
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _isGuindaTheme = prefs.getBool(_themeKey) ?? true;
    notifyListeners();
  }

  /// Cambiar entre modo claro y oscuro
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }

  /// Cambiar entre tema Guinda y Azul
  Future<void> toggleTheme() async {
    _isGuindaTheme = !_isGuindaTheme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isGuindaTheme);
    notifyListeners();
  }

  /// Establecer tema específico
  Future<void> setTheme(bool isGuinda) async {
    if (_isGuindaTheme != isGuinda) {
      _isGuindaTheme = isGuinda;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themeKey, _isGuindaTheme);
      notifyListeners();
    }
  }
}