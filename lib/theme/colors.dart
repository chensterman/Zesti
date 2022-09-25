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

/* COLORS: can revamp coloring system, 
organize most common colors 
and label their use
*/
class Colors {
  Color reallyBrightOrange = Color(0xFFFD6000);
  Color mildlyBrightOrange = Color(0xFFFC8D4C);
  Color peachyOrange = Color(0xFFFF8E6A);
  Color transitioningOrange = Color(0xFFFFC984);
  Color cream = Color(0xFFFAF2E9);
// DELETED MINT GREEN
  Color black = Color.fromARGB(255, 5, 5, 5);
}
