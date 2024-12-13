import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeProvider with ChangeNotifier {
  ThemeData _currentTheme = ThemeData.light();
  ThemeData get currentTheme => _currentTheme;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    if (_currentTheme == ThemeData.light()) {
      _currentTheme = ThemeData.dark();
    } else {
      _currentTheme = ThemeData.light();
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
              data['isDarkTheme'] ? ThemeData.dark() : ThemeData.light();
        }
      }
    }
    notifyListeners();
  }

  Future<void> reloadTheme() async {
    await _loadTheme();
  }
}
