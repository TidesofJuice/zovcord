import 'package:flutter/material.dart';

class PinkTheme {
  static ThemeData get pink {
    return ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xffd35c9c),
          onPrimary: Colors.white,
          secondary: Color(0xffd3abd3),
          onSecondary: Colors.black,
          tertiary: Color(0xff62c9f5),
          onTertiary: Colors.black,
          outline: Colors.white,
          error: const Color.fromARGB(255, 255, 63, 49),
          onError: Colors.white,
          surface: Color(0xffd3abd3),
          onSurface: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xffd35c9c),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white, applyTextScaling: true),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xff6381c2),
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xffd35c9c),
        size: 24,
      ),
    );
  }
}
