import 'package:flutter/material.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get appbar1 {
    return const TextStyle(
        inherit: true,
        fontSize: 24.0,
        color: Colors.white,
        shadows: [
          Shadow(
              // bottomLeft
              offset: Offset(-1, -1),
              color: Colors.black),
          Shadow(
              // bottomRight
              offset: Offset(1, -1),
              color: Colors.black),
          Shadow(
              // topRight
              offset: Offset(1, 1),
              color: Colors.black),
          Shadow(
              // topLeft
              offset: Offset(-1, 1),
              color: Colors.black),
        ]);
  }
}
