import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xff3b3a4a),
          onPrimary: Colors.white,
          secondary: Color(0xff252330) ,
          onSecondary: Colors.white,
          tertiary: Color(0xff575669),
          onTertiary: Colors.black,
          outline: Colors.white,
          error: const Color.fromARGB(255, 255, 63, 49),
          onError: Colors.white,
          surface: Color(0xff595168),
          onSurface: Colors.white),
          

          appBarTheme: AppBarTheme(
            backgroundColor: Color(0xff3b3a4a),
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(
              color: Color(0xfff5f9f8),
              applyTextScaling: true
            ),
          ), 
          buttonTheme: ButtonThemeData(
            buttonColor: Color(0xff3b3a4a),
            textTheme: ButtonTextTheme.normal,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          iconTheme: IconThemeData(
            color: Color(0xffa1a2ab),
            size: 24,
          ),
          
    );
  }
}