import 'package:flutter/material.dart';

// Class containing app themes (colors, fonts, etc.)
class CustomTheme {
  static var containerWidth = 0.85;
  static double containerPadding = 20;
  static Color gray = Color(0xFFDCDCDC);
  static ThemeData get lightTheme {
    //1
    return ThemeData(
        //2
        primaryColor: Color(0xFFFD6000),
        primaryColorDark: Color(0xFFFC8D4C),
        primaryColorLight: Color(0xFFFF8E6A),
        backgroundColor: Color(0xFFFFC984),
        cardColor: Color(0xFFFAF2E9),
        splashColor: Color(0xFFC6F7A6),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Jost', //3
        textTheme: TextTheme(
          headline1: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'Jost'),
          headline2: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          bodyText2: TextStyle(fontSize: 16, fontFamily: 'Hind'),
        ),
        buttonTheme: ButtonThemeData(
          // 4
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
          buttonColor: Colors.blue,
        ));
  }
}
