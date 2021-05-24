import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/swipe.dart';

class Info extends StatefulWidget {
  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> {
  final _formKey = GlobalKey<FormState>();
  dynamic imageFile;
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  String bio = '';

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

  void clearImage() {
    setState(() => imageFile = null);
  }

  Future<void> uploadImage(File image) async {
    try {
      await _storage
          .ref("profpics/" + DateTime.now().toString())
          .putFile(image);
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);
    return Scaffold(
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
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
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
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "and say something cool!",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                TextFormField(
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return "Please enter a first name.";
                    }
                  },
                  onChanged: (val) {
                    setState(() => bio = val);
                  },
                  decoration: const InputDecoration(hintText: "First"),
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
                        if (_formKey.currentState!.validate()) {
                          if (user == null) {
                            print("Error");
                          } else {
                            await DatabaseService(uid: user.uid).updateBio(bio);
                          }
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Swipe()),
                        );
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

  Widget profileImage() {
    ImageProvider<Object>? bgImage;
    if (imageFile == null) {
      bgImage = AssetImage("assets/profile.jpeg");
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
          bottom: 10.0,
          right: 10.0,
          child: InkWell(
              onTap: () {
                showModalBottomSheet(
                    context: context, builder: (builder) => bottomSheet());
              },
              child: Icon(
                Icons.camera_alt,
                color: Colors.grey,
                size: 28.0,
              )),
        ),
      ],
    );
  }

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
