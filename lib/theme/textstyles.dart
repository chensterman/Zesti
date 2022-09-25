import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/theme/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/widgets/errors.dart';
import 'package:zesti/widgets/loading.dart';
import 'package:zesti/views/register/identity.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

// TEXT: organize most common text styles and label them for what they are and can be used for
class TextStyles {
  static TextTheme textTheme = TextTheme(
    headline1: TextStyle(
      color: CustomTheme.reallyBrightOrange,
      fontSize: 30,
      fontWeight: FontWeight.bold,
      fontFamily: 'Hind',
    ),
    headline2: TextStyle(
        color: CustomTheme.blackText,
        fontSize: 30,
        fontWeight: FontWeight.bold,
        fontFamily: 'Hind'),
    headline3: TextStyle(
      color: CustomTheme.reallyBrightOrange,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Hind',
    ),
    // DELETED HEADLINE4 AND HEADLINE5
    //CHANGED HEADLINE FONTS TO HIND
    // DELETED SHADOWS (experiment)
    bodyText1: TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'Hind'),
    bodyText2: TextStyle(
        color: CustomTheme.reallyBrightOrange,
        fontSize: 16,
        fontFamily: 'Hind'),
    //DELETED SUBTITLE1
    subtitle2: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'Hind'),
  );
}
