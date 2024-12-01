import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  ThemeData get currentTheme => _currentTheme;
  ThemeProvider() {
    _loadTheme();
  }
  void toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (_currentTheme == ThemeData.light()) {
      _currentTheme = ThemeData.dark();
      await prefs.setBool('isDarkTheme', true);
    } else {
      _currentTheme = ThemeData.light();
      await prefs.setBool('isDarkTheme', false);
    }
    notifyListeners();
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;
    _currentTheme = isDarkTheme ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }
}
