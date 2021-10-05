import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/register/zestkey.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for profile picture upload and bio
class Info extends StatefulWidget {
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  // Form widget key.
  final _formKey = GlobalKey<FormState>();

  // Image and storage variables.
  dynamic imageFile;
  final ImagePicker _picker = ImagePicker();

  // Mutable bio.
  String bio = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
      ),
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: Container(
            child: Form(
              key: _formKey,
              child: Center(
                child: ListView(shrinkWrap: true, children: <Widget>[
                  Center(
                    child: Column(
                      children: [
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: EdgeInsets.all(32.0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 32.0, horizontal: 32.0),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 32.0),
                                  child: Text(
                                    "Upload your best picture...",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 64.0),
                                  child: profileImage(),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 32.0),
                                  child: Text(
                                    "and say something cool!",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                TextFormField(
                                  validator: (val) {
                                    if (val == null || val.isEmpty) {
                                      return "Please enter a bio.";
                                    }
                                    if (val.length > 140) {
                                      return "Please enter a shorter bio (140 characters max).";
                                    }
                                  },
                                  onChanged: (val) {
                                    setState(() => bio = val);
                                  },
                                  decoration:
                                      const InputDecoration(hintText: "Bio"),
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                  text: "Continue",
                                  onPressed: () async {
                                    // Form validation:
                                    //  Does nothing if validation is incorrect.
                                    if (_formKey.currentState!.validate()) {
                                      // Do not upload if dynamic imageFile is null.
                                      if (imageFile != null) {
                                        // Update user document with the reference.
                                        await DatabaseService(uid: user!.uid)
                                            .updatePhoto(imageFile);
                                      }
                                      // Update user document with bio.
                                      await DatabaseService(uid: user!.uid)
                                          .updateBio(bio);
                                      // Flag account as fully set up
                                      await DatabaseService(uid: user.uid)
                                          .updateAccountSetup();
                                      // Navigate accordingly.
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ZestKey()),
                                      );
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Image Picker:
  //  Sets dynamic Imagefile to an image file if possible.
  Future<void> pickImage(ImageSource source) async {
    final selected = await _picker.getImage(source: source);

    setState(() {
      if (selected == null) {
        print("Error");
      } else {
        File file = File(selected.path);
        imageFile = file;
      }
    });
  }

  // Clears the image:
  //  Reverts the dynamic ImageFile back to null.
  void clearImage() {
    setState(() => imageFile = null);
  }

  // Widget for profile image chooser.
  Widget profileImage() {
    // Instantiate the background image.
    ImageProvider<Object>? bgImage;

    // Update the background image according to the dynamic imageFile.
    if (imageFile == null) {
      bgImage = AssetImage("assets/profile.jpg");
    } else {
      bgImage = FileImage(File(imageFile.path));
    }

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
                    context: context, builder: (builder) => bottomSheet());
              },
              child: Icon(
                Icons.add_circle,
                color: Colors.green,
                size: 36.0,
              )),
        ),
        Positioned(
          top: 2.0,
          right: 2.0,
          child: InkWell(
              onTap: () {
                clearImage();
              },
              child: Icon(
                Icons.do_not_disturb_on,
                color: Colors.red,
                size: 36.0,
              )),
        ),
      ],
    );
  }

  // Widget for the image choosing bottom sheet (camera or gallery).
  Widget bottomSheet() {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 100.0,
      width: size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: Column(children: [
        Text("Choose Profile Photo", style: TextStyle(fontSize: 20)),
        SizedBox(height: 8.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: Icon(Icons.camera, color: Colors.grey),
              onPressed: () {
                pickImage(ImageSource.camera);
              },
              label: Text("Camera", style: TextStyle(color: Colors.grey)),
            ),
            TextButton.icon(
              icon: Icon(Icons.image, color: Colors.grey),
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
