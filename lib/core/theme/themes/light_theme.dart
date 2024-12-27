import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xff3684db),
          onPrimary: Colors.white,
          secondary: Color(0xffb3d6f9),
          onSecondary: Colors.black,
          tertiary: Color(0xff758ba5),
          onTertiary: Colors.white,
          outline: Colors.black,
          error: const Color.fromARGB(255, 255, 63, 49),
          onError: Colors.black,
          surface: Color(0xffd1dded),
          onSurface: Colors.black),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xff3684db),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: Colors.white, applyTextScaling: true),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xff3684db),
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xff3684db),
        size: 24,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
    );
  }
}
