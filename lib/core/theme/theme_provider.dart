import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zovcord/core/theme/themes/light_theme.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = LightTheme.lightTheme;
  ThemeData get currentTheme => _currentTheme;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    if (_currentTheme == LightTheme.lightTheme) {
      _currentTheme = ThemeData.dark();
    } else {
      _currentTheme = LightTheme.lightTheme;
    }

    await _saveThemeToFirestore(_currentTheme == ThemeData.dark());

    notifyListeners();
  }

  Future<void> _saveThemeToFirestore(bool isDarkTheme) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).set(
        {'isDarkTheme': isDarkTheme},
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
        if (data != null && data.containsKey('isDarkTheme')) {
          _currentTheme =
              data['isDarkTheme'] ? ThemeData.dark() : LightTheme.lightTheme;
        }
      }
    }
    notifyListeners();
  }

  Future<void> reloadTheme() async {
    await _loadTheme();
  }
}
