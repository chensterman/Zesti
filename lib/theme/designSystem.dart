/*
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
class CustomTheme {
  
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
    bodyText1: TextStyle(
      color: Colors.black, 
      fontSize: 16, 
      fontFamily: 'Hind'),
    bodyText2: TextStyle(
        color: CustomTheme.reallyBrightOrange,
        fontSize: 16,
        fontFamily: 'Hind'),
    //DELETED SUBTITLE1
    subtitle2: TextStyle(
      color: Colors.white, 
      fontSize: 20, 
      fontFamily: 'Hind'),
  );


/* COLORS: can revamp coloring system, 
organize most common colors 
and label their use
*/
static Color reallyBrightOrange = Color(0xFFFD6000);
static Color mildlyBrightOrange = Color(0xFFFC8D4C);
static Color peachyOrange = Color(0xFFFF8E6A);
static Color transitioningOrange = Color(0xFFFFC984);
static Color cream = Color(0xFFFAF2E9);
// DELETED MINT GREEN
static Color blackText = Colors.black54;
}//custom theme class


//Circle icons

//1. Red X on recommendations/requests
// from usercard.dart
// changed color to white
@override
Widget build(BuildContext context) {
Padding(
  padding: EdgeInsets.all(16.0),
  child: InkWell(
    child: Icon(Icons.cancel_rounded,
        color: Colors.white, size: 64.0),
  )
)
}

//2. send button on recommendations/requests
// from usercard.dart
  @override
  Widget build(BuildContext context) {
Padding(
  padding: EdgeInsets.all(16.0),
  child: InkWell(
    child: Icon(rec ? Icons.send : Icons.check_circle,
        color: key ? Colors.white : Colors.white,
        size: 64.0)
  )
)
  }


//refresh button 
// recommendations.dart 
  @override
  Widget build(BuildContext context) {
return Center(
  child: RoundedButton(
    text: "Refresh",
    color: CustomTheme.mildlyBrightOrange,
    onPressed: () async {
      ZestiLoadingAsync().show(context);
      bool status =
          await DatabaseService(uid: widget.uid)
              .updateRecRefresh(DateTime.now());
      ZestiLoadingAsync().dismiss();
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              refreshStatusDialog(context, status));
    },
  ),
);
  }

//solo vs group 
// solo icon
// home.dart 
  @override
  Widget build(BuildContext context) {
Container(
  child: SizedBox(
    width: 100.0,
    height: 100.0,
    child: SvgPicture.asset(
        "assets/Solo.svg"),
  ),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
          blurRadius: 5,
          color:
              Colors.grey.shade700,
          spreadRadius: -2)
    ],
  ),
)
  }

// solo text rounded button
// home.dart 
  @override
  Widget build(BuildContext context) {
Container(
  width: 100.0,
  padding: EdgeInsets.all(8.0),
  child: Center(
  child: Align(
      alignment:
          Alignment.center,
      child: Text("Solo",
          style: CustomTheme
              .textTheme
              .headline3))),
  decoration: BoxDecoration(
  color: Colors.white,
  borderRadius:
    BorderRadius.circular(20),
  boxShadow: [
  BoxShadow(
      offset: Offset(3.0, 3.0),
      blurRadius: 5,
      color:
          Colors.grey.shade700,
      spreadRadius: 3)
  ],
  ),
  )
  }

// group icon
// home.dart
  @override
  Widget build(BuildContext context) {
Container(
  child: SizedBox(
    width: 100.0,
    height: 100.0,
    child: SvgPicture.asset(
        "assets/Group.svg"),
  ),
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
          blurRadius: 5,
          color:
              Colors.grey.shade700,
          spreadRadius: -2)
    ],
  ),
),
  }


// group text 
// home.dart
  @override
  Widget build(BuildContext context) {
Container(
  width: 100.0,
  padding: EdgeInsets.all(8.0),
  child: Center(
      child: Align(
          alignment:
              Alignment.center,
          child: Text("Group",
              style: CustomTheme
                  .textTheme
                  .headline3))),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius:
        BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
          offset: Offset(3.0, 3.0),
          blurRadius: 5,
          color:
              Colors.grey.shade700,
          spreadRadius: 3)
    ],
  ),
)
  }


//3. friendship and love 
// changed friendship color
// from previewcard.dart 
@override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: size.height * 0.7,
      width: size.width * 0.95,
      child: Stack(
        children: [
          Positioned(
              left: 10,
              top: 10,
               child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  userOnCard.dIntent == "both" ||
                          userOnCard.dIntent == "friendship"
                      ? intentTagTile("Friendship", CustomTheme.reallyBrightOrange)
                      : Container(),
                  userOnCard.dIntent == "both" || userOnCard.dIntent == "love"
                      ? intentTagTile("Love", CustomTheme.reallyBrightOrange)
                      : Container(),
                ]
              )
            )
        ]
       )
    )
  }

//zesti logo size (not on app bar)
final Size size = MediaQuery.of(context).size;
double logoWidth = size.width * 0.8;
double logoHeight = size.height * 0.4;

/*
class Sizes {
  final Size size;
  size = MediaQuery.of(context).size;
  Static Size logoSize = Size {
    this.width = size.width * 0.8;
  }
}
zesti logo object
- height
- width

card size?

icon sizing 

avoid hard coded pixel values 

widget sizing - margins, paddings (ex: match sheets)

common seperators --> or maybe make widget instead of in size 
*/

// card size 
// user.dart
@override
Widget build(BuildContext context) {
  final Size size = MediaQuery.of(context).size;
    return Container(
                height: size.height * 0.7,
                width: size.width * 0.95,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                )
                );
  }



//bottom navigation  bar icons
@override
  Widget build(BuildContext context) {
    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      Group(gid: widget.gid),
      Recommendations(gid: widget.gid),
      Requests(gid: widget.gid),
      Matches(gid: widget.gid),
    ];
    // Main page widget (contains nav bar pages as well)
    return Scaffold(
    bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        items: <Widget>[
          Icon(Icons.groups),
          Icon(Icons.hourglass_top),
          Icon(Icons.mood),
          Icon(Icons.chat_bubble),
        ],
        onTap: _onItemTapped,
      ),
    )
  }

// top app bar zesti logo 
@override
Widget build(BuildContext context) {
  return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: SizedBox(
          height: 50.0,
          child: SvgPicture.asset(
            "assets/zesti.svg",
            alignment: Alignment.centerLeft,
          ),
        )
      )
  )
}


//chats sizing  
// *** check percentages 
double chatWidth = size.width * 0.95;
double chatHeight = size.height * 0.25; 

// form widgets
// Text input used across multiple forms.
class TextFieldContainer extends StatelessWidget {
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final String? hintText;
  final Icon? icon;
  final Widget? suffixIcon;
  TextFieldContainer({
    Key? key,
    this.obscureText = false,
    this.validator,
    this.onChanged,
    this.hintText,
    this.icon,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      width: size.width * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
      ),
      child: TextFormField(
        obscureText: obscureText,
        validator: validator,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          icon: icon,
          border: InputBorder.none,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}

// Rounded button used across multiple forms.
class RoundedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double fontSize;
  final double verticalEdgeInsets;
  final double horizontalEdgeInsets;
  RoundedButton({
    Key? key,
    this.text = '',
    this.onPressed,
    this.color,
    this.fontSize = 16,
    this.verticalEdgeInsets = 20,
    this.horizontalEdgeInsets = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.5,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: color != null ? color : CustomTheme.reallyBrightOrange,
            padding: EdgeInsets.symmetric(
                vertical: verticalEdgeInsets, horizontal: horizontalEdgeInsets),
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0))),
        onPressed: onPressed,
        child: Center(
            child: Text(
          text,
          style: TextStyle(fontSize: fontSize),
          textAlign: TextAlign.center,
        )),
      ),
    );
  }
}

class DropDownField extends StatelessWidget {
  final Function callback;
  final String? initValue;
  final List<String> houseList;
  DropDownField({
    Key? key,
    required this.callback,
    required this.initValue,
    required this.houseList,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: CustomTheme.reallyBrightOrange),
          borderRadius: BorderRadius.circular(10)),
      child: DropdownButton<String>(
        underline: Container(),
        iconSize: 32.0,
        icon: Icon(
          Icons.arrow_drop_down,
          color: CustomTheme.reallyBrightOrange,
        ),
        value: initValue,
        hint: Text('Select'),
        style: TextStyle(color: Colors.black),
        isExpanded: true,
        items: houseList.map((val) {
          return DropdownMenuItem(
              value: val,
              child: Text(val, style: CustomTheme.textTheme.headline5));
        }).toList(),
        onChanged: (String? val) {
          this.callback(val);
        },
      ),
    );
  }
}

class ImageUpdate extends StatelessWidget {
  final Function callback;
  final dynamic profpic;
  ImageUpdate({
    Key? key,
    required this.callback,
    required this.profpic,
  }) : super(key: key);

  // Image picker tool.
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    // Instantiate the image.
    ImageProvider<Object>? bgImage;

    // Update the image according to the dynamic imageFile.
    if (profpic == null) {
      bgImage = AssetImage("assets/profile.jpg");
    } else if (profpic is ImageProvider<Object>) {
      bgImage = profpic;
    } else {
      bgImage = FileImage(File(profpic.path));
    }

    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        CircleAvatar(
          radius: 80.0,
          backgroundImage: bgImage,
          backgroundColor: Colors.white,
        ),
        Positioned(
          bottom: 0.0,
          right: 4.0,
          child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) => bottomSheet(context, size));
              },
              child: Icon(
                Icons.add_photo_alternate_rounded,
                color: Colors.green,
                size: 36.0,
              )),
        ),
        // Positioned(
        //   top: 2.0,
        //   right: 2.0,
        //   child: InkWell(
        //       onTap: () {
        //         clearImage();
        //       },
        //       child: Icon(
        //         Icons.do_not_disturb_on,
        //         color: Colors.red,
        //         size: 36.0,
        //       )),
        // ),
      ],
    );
  }

  // Image Picker:
  //  Sets dynamic Imagefile to an image file if possible.
  Future<void> pickImage(BuildContext context, ImageSource source) async {
    // On failure (usualy due to large files), getImage() returns null pointer.
    final selected = await _picker.getImage(source: source);

    // On null pointer returned, display error and return.
    if (selected == null) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => imageSizeDialog(
                context,
              ));
    } else {
      // Check for file size.
      File file = File(selected.path);
      int sizeInBytes = file.lengthSync();
      double sizeInMb = sizeInBytes / (1024 * 1024);
      if (sizeInMb > 8) {
        // This file is too large
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => imageSizeDialog(
                  context,
                ));
      } else {
        // Update image through callback function.
        this.callback(file);
      }
    }
  }

  // // Clears the image:
  // //  Reverts the dynamic ImageFile back to null.
  // void clearImage() {
  //   this.callback(null);
  // }

  // Alert for image size too large.
  Widget imageSizeDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text("File error. Your image may be too large (over 8MB)!"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child:
              SvgPicture.asset("assets/warning.svg", semanticsLabel: "Warning"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Ok", style: CustomTheme.textTheme.headline2),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  // Widget for the image choosing bottom sheet (camera or gallery).
  Widget bottomSheet(BuildContext context, Size size) {
    return Container(
      height: 200.0,
      width: size.width * 0.75,
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(25.0)),
      ),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text("Choose Profile Photo", style: TextStyle(fontSize: 20)),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(
              icon: Icon(
                Icons.camera,
                color: Colors.grey,
                size: 48.0,
              ),
              onPressed: () {
                pickImage(context, ImageSource.camera);
              },
              label: Text("Camera", style: TextStyle(color: Colors.grey)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.grey, size: 48.0),
              onPressed: () {
                pickImage(context, ImageSource.gallery);
              },
              label: Text("Gallery", style: TextStyle(color: Colors.grey)),
            ),
          ],
        )
      ]),
    );
  }
}


// error widgets
// Text input used across multiple forms.
class Empty extends StatelessWidget {
  final String reason;
  Empty({
    Key? key,
    required this.reason,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(top: 24.0, right: 8.0, left: 8.0, bottom: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(reason,
                textAlign: TextAlign.left,
                style: CustomTheme.textTheme.headline2),
            SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              height: size.height * 0.3,
              child:
                  SvgPicture.asset("assets/empty.svg", semanticsLabel: "Name"),
            ),
          ],
        ),
      ),
    );
  }
}

// Rounded looking button used across multiple forms.
class NotFound extends StatelessWidget {
  final String reason;
  final DocumentReference doc;
  NotFound({
    Key? key,
    required this.reason,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.only(top: 16.0, right: 8.0, left: 8.0, bottom: 8.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(reason,
                textAlign: TextAlign.center,
                style: CustomTheme.textTheme.headline2),
            SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              height: size.height * 0.3,
              child: SvgPicture.asset("assets/notfound.svg",
                  semanticsLabel: "Name"),
            ),
            InkWell(
              child: Icon(Icons.cancel_rounded, color: Colors.red, size: 64.0),
              onTap: () async {
                ZestiLoadingAsync().show(context);
                await doc.delete();
                ZestiLoadingAsync().dismiss();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Rounded looking button used across multiple forms.
class NotFoundMatchSheet extends StatelessWidget {
  final DocumentReference doc;
  NotFoundMatchSheet({
    Key? key,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      margin: EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () async {
          ZestiLoadingAsync().show(context);
          await doc.delete();
          ZestiLoadingAsync().dismiss();
        },
        // Display match info (user data) on the sheet.
        child: Container(
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: 160.0,
                  height: 16.0,
                  child: SvgPicture.asset("assets/name.svg",
                      semanticsLabel: "Name"),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("This group disbanded :(",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    SizedBox(height: 10.0),
                    Text('Sorry... tap to remove',
                        style: TextStyle(fontSize: 16))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// loading widgets 
/// This is the stateful widget that the main application instantiates.
class ZestiLoading extends StatefulWidget {
  const ZestiLoading({Key? key}) : super(key: key);

  @override
  State<ZestiLoading> createState() => _ZestiLoadingState();
}

/// This is the private State class that goes with MyStatefulWidget.
/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _ZestiLoadingState extends State<ZestiLoading>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 5),
    vsync: this,
  )..repeat(reverse: true);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticOut,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _animation,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            height: 50.0,
            child: SvgPicture.asset(
              "assets/loading.svg",
            ),
          ),
        ),
      ),
    );
  }
}

class ZestiLoadingAsync {
  static final ZestiLoadingAsync _singleton = ZestiLoadingAsync._internal();
  BuildContext? _context;

  factory ZestiLoadingAsync() {
    return _singleton;
  }

  ZestiLoadingAsync._internal();

  show(BuildContext context) {
    showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          _context = context;
          return WillPopScope(
            onWillPop: () async => false,
            child: ZestiLoading(),
          );
        });
  }

  dismiss() {
    if (_context != null) {
      Navigator.of(_context!).pop();
    }
  }
}

*/