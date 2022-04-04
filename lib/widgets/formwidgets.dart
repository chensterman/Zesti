// Dart file container various widgets used across the app
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zesti/theme/theme.dart';

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

// Rounded looking button used across multiple forms.
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
            padding: EdgeInsets.symmetric(vertical: verticalEdgeInsets, horizontal: horizontalEdgeInsets),
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
                    builder: (builder) => bottomSheet(size));
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
  Future<void> pickImage(ImageSource source) async {
    final selected = await _picker.getImage(source: source);
    File file = File(selected!.path);
    this.callback(file);
  }

  // // Clears the image:
  // //  Reverts the dynamic ImageFile back to null.
  // void clearImage() {
  //   this.callback(null);
  // }

  // Widget for the image choosing bottom sheet (camera or gallery).
  Widget bottomSheet(Size size) {
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
                pickImage(ImageSource.camera);
              },
              label: Text("Camera", style: TextStyle(color: Colors.grey)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.grey, size: 48.0),
              onPressed: () {
                pickImage(ImageSource.gallery);
              },
              label: Text("Gallery", style: TextStyle(color: Colors.grey)),
            ),
          ],
        )
      ]),
    );
  }
}
