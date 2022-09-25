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
import 'package:flutter/src/widgets/media_query.dart';
import 'package:zesti/theme/sizes.dart';

//all margins and paddings are edgeinsets.all only

//height and width needs to be double check
// currently assumed as 1440 x 2560 at 560 dpi (sample resolution from nexus 6 api 28)

class Sizes {
  /*MediaQueryData size =
      MediaQueryData.fromWindow(WidgetsBinding.instance.window);
  double screenSize = size.size;
*/
  //User card Size and Group card size
  double cardWidth = 0.95;
  double cardHeight = 0.7;

  //Card margins
  // 20.0
  double cardMargin = 0.0000054;

  //Card padding
  // 16.0
  double cardPadding = 0.0000043;

  //Icon size
  // cancel rounded, send, green check
  // 64.0
  double iconSize = 0.000017;

  //Form widget
  double formWidth = 0.5;
  double formHeightSmall = 0.000041; //150
  double formHeightLarge = 0.000054; //200
  double formMargin = 0.0000054; //20.0
  double formSheetPadding = 0.0000054; //20.0

  //Error widget
  double errorPadding = 0.0000043; //16.0
  double errorHeight = 0.3;
  //error width - infinty?
  double errorMargin = 0.0000022; //8.0

  //Loading widget
  double loadingHeight = 0.000014; //50.0
  double loadingPadding = 0.0000022; //8.0

  //Spacing
  // currently being used: 4, 8, 10, 16, 20, 32, 40, 50
  double spacing4 = 0.0000011; //4
  double spacing9 = 0.0000024; //9
  double spacing16 = 0.0000043; //16
  double spacing20 = 0.0000054; //20 - most common
  double spacing32 = 0.0000086; //32
  double spacing45 = 0.000012; //45
}
