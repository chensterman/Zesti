import 'package:flutter/material.dart';

// Class containing app themes (colors, fonts, etc.)
class CustomTheme {
  // Widget sizing.
  static double containerWidth = 0.85;
  static double paddingMultiplier = 0.1;

  // Color scheme.
  static Color reallyBrightOrange = Color(0xFFFD6000);
  static Color mildlyBrightOrange = Color(0xFFFC8D4C);
  static Color peachyOrange = Color(0xFFFF8E6A);
  static Color transitioningOrange = Color(0xFFFFC984);
  static Color cream = Color(0xFFFAF2E9);
  static Color mintyGreen = Color(0xFFC6F7A6);
  static Color gray = Color(0xFFDCDCDC);

  // Text theme.
  static TextTheme textTheme = TextTheme(
    headline1: TextStyle(
        color: CustomTheme.reallyBrightOrange,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        fontFamily: 'Jost'),
    headline2: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    headline3: TextStyle(
        color: CustomTheme.reallyBrightOrange,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Jost'),
    bodyText1: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Hind'),
    bodyText2: TextStyle(
        color: CustomTheme.reallyBrightOrange,
        fontSize: 16,
        fontFamily: 'Hind'),
  );

  // Container gradients.
  static BoxDecoration standard = BoxDecoration(
    // Box decoration takes a gradient.
    gradient: LinearGradient(
      // Where the linear gradient begins and ends.
      begin: Alignment.topRight,
      end: Alignment.bottomLeft,
      // Add one stop for each color. Stops should increase from 0 to 1.
      stops: [0.1, 0.6, 0.9],
      colors: [
        CustomTheme.cream,
        CustomTheme.transitioningOrange,
        CustomTheme.reallyBrightOrange,
      ],
    ),
  );
  static BoxDecoration mode = BoxDecoration(
    // Box decoration takes a gradient.
    gradient: LinearGradient(
      // Where the linear gradient begins and ends.
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      // Add one stop for each color. Stops should increase from 0 to 1.
      stops: [0.3, 0.9],
      colors: [
        CustomTheme.cream,
        CustomTheme.reallyBrightOrange,
      ],
    ),
  );
}
