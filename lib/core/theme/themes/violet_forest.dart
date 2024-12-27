import 'package:flutter/material.dart';

class VioletForest {
  static ThemeData get violet {
    return ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xff554690),
          onPrimary: Colors.white,
          secondary: Color(0xff372e6a),
          onSecondary: Colors.white,
          tertiary: Color(0xffa67fab),
          onTertiary: Colors.black,
          outline: Colors.white,
          error: const Color.fromARGB(255, 255, 63, 49),
          onError: Colors.white,
          surface: Color(0xff252257),
          onSurface: Colors.white),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xff554690),
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        iconTheme:
            IconThemeData(color: Color(0xffedd1d2), applyTextScaling: true),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Color(0xff372e6a),
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      iconTheme: IconThemeData(
        color: Color(0xffedd1d2),
        size: 24,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
    );
  }
}
