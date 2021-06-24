import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/home.dart';

class EditProfile extends StatelessWidget {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String uid;
  EditProfile({
    Key? key,
    required this.uid,
  }) : super(key: key);

  // Uploads image:
  //  Creates unique storage reference (currently using DateTime) and
  //  stores the image file onto it. Returns the storage reference as
  //  a string in order to update the user document later.
  Future<Map<String, dynamic>> _getInfo(String uid) async {
    Map<String, dynamic> data = await DatabaseService(uid: uid).getInfo();
    Uint8List? profpic =
        await _storage.ref().child(data['photo-ref']).getData();
    if (profpic == null) {
      data['prof-pic'] = null;
    } else {
      data['prof-pic'] = MemoryImage(profpic);
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        // FutureBuilder for http request payload
        child: FutureBuilder(
          future: _getInfo(uid),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            // On error
            if (snapshot.hasError) {
              return Text("Error");
            }
            // On success
            else if (snapshot.connectionState == ConnectionState.done) {
              Map<String, dynamic>? data = snapshot.data;
              if (data == null) {
                return Text('Error');
              } else {
                return ProfileForm(
                  bio: data['bio'],
                  profpic: data['prof-pic'],
                );
              }
            }
            // Otherwise, return a loading screen
            else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}

class ProfileForm extends StatefulWidget {
  final String bio;
  final MemoryImage? profpic;
  ProfileForm({
    Key? key,
    required this.bio,
    required this.profpic,
  }) : super(key: key);

  @override
  _ProfileFormState createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  // Form widget key.
  final _formKey = GlobalKey<FormState>();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User data to retrieve and display.
  String bio = '';
  dynamic profpic;

  @override
  void initState() {
    super.initState();
    bio = widget.bio;
    profpic = widget.profpic;
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
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64.0),
                    child: profileImage(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please say something at least mildly entertaining.";
                        }
                      },
                      onChanged: (val) {
                        setState(() => bio = val);
                      },
                      decoration: const InputDecoration(labelText: 'Bio'),
                      initialValue: bio,
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please say something at least mildly entertaining.";
                        }
                      },
                      onChanged: (val) {
                        setState(() => bio = val);
                      },
                      decoration: const InputDecoration(labelText: 'Bio'),
                      initialValue: bio,
                      maxLines: 3,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: TextFormField(
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Please say something at least mildly entertaining.";
                        }
                      },
                      onChanged: (val) {
                        setState(() => bio = val);
                      },
                      decoration: const InputDecoration(labelText: 'Bio'),
                      initialValue: bio,
                      maxLines: 3,
                    ),
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
                            if (user != null) {
                              await DatabaseService(uid: user.uid)
                                  .updateBio(bio);
                            }
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
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
        profpic = file;
      }
    });
  }

  // Clears the image:
  //  Reverts the dynamic ImageFile back to null.
  void clearImage() {
    setState(() => profpic = null);
  }

  // Widget for profile image chooser.
  Widget profileImage() {
    // Instantiate the background image.
    ImageProvider<Object>? bgImage;

    // Update the background image according to the dynamic imageFile.
    if (profpic == null) {
      bgImage = AssetImage("assets/profile.jpg");
    } else {
      bgImage = profpic;
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
