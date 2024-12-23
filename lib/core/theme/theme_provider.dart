import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zovcord/core/theme/themes/dark_theme.dart';
import 'package:zovcord/core/theme/themes/light_theme.dart';
import 'package:zovcord/core/theme/themes/pink_theme.dart';
import 'package:zovcord/core/theme/themes/violet_forest.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = LightTheme.lightTheme;
  ThemeData get currentTheme => _currentTheme;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(int value) async {
    switch (value) { 
      case 1:
      _currentTheme = LightTheme.lightTheme;
      break;
      case 2:
      _currentTheme = DarkTheme.darkTheme;
      break;
      case 3:
      _currentTheme = VioletForest.violet;
      break;
      case 4:
      _currentTheme = PinkTheme.pink;
    }

    await _saveThemeToFirestore(value);

    notifyListeners();
  }

  Future<void> _saveThemeToFirestore(int themeValue) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).set(
        {'theme': themeValue},
        SetOptions(merge: true),
      );
    }
  }

  Future<void> _loadTheme() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('Users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('theme')) {
        final themeValue = doc.data()!['theme'];
        toggleTheme(themeValue);
      }
      }
    }
    notifyListeners();
  }

  Future<void> reloadTheme() async {
    await _loadTheme();
  }
}
