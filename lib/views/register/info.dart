import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/wrappers/swipewrapper.dart';

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
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Mutable bio.
  String bio = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
      ),
      body: Center(
        child: Container(
          width: size.width * CustomTheme.containerWidth,
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    "Upload your best picture...",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 64.0),
                  child: profileImage(),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32.0),
                  child: Text(
                    "and say something cool!",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                TextFormField(
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please say something at least mildly entertaining.";
                    }
                  },
                  onChanged: (val) {
                    setState(() => bio = val);
                  },
                  decoration: const InputDecoration(hintText: "Bio"),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: CustomTheme.lightTheme.primaryColor,
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, right: 30, bottom: 10),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                      onPressed: () async {
                        // Form validation:
                        //  Does nothing if validation is incorrect.
                        if (_formKey.currentState!.validate()) {
                          // Check for null user.
                          if (user != null) {
                            // Do not upload if dynamic imageFile is null.
                            if (imageFile != null) {
                              // Upload image and store the reference.
                              String storageRef =
                                  await uploadImage(imageFile, user.uid);
                              // Update user document with the reference.
                              await DatabaseService(uid: user.uid)
                                  .updatePhoto(storageRef);
                            }
                            // Update user document with bio.
                            await DatabaseService(uid: user.uid).updateBio(bio);
                          }
                          // Navigate accordingly.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SwipeWrapper()),
                          );
                        }
                      },
                      child: Text("I'm Ready!"),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Uploads image:
  //  Creates unique storage reference (currently using DateTime) and
  //  stores the image file onto it. Returns the storage reference as
  //  a string in order to update the user document later.
  Future<String> uploadImage(File image, String uid) async {
    String storageRefPut = "profpics/" + DateTime.now().toString() + ".jpg";
    await _storage.ref(storageRefPut).putFile(image);
    return storageRefPut;
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
