import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/home.dart';
import 'package:zesti/widgets/usercard.dart';

// Widget for the profile edit.
class Profile extends StatefulWidget {
  final String uid;
  Profile({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  // Form widget key.
  final _formKey = GlobalKey<FormState>();

  // Image picker tool.
  final ImagePicker _picker = ImagePicker();

  // User data to retrieve and display.
  String? name;
  String? bio;
  String? house;
  String? photoref;
  dynamic profpic;

  // Stream to retrieve user profile information (initialized during initState).
  Stream<DocumentSnapshot>? profileInfo;

  @override
  void initState() {
    profileInfo = DatabaseService(uid: widget.uid).getProfileInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder to display profile info stream.
    return StreamBuilder(
        stream: profileInfo,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          DocumentSnapshot? tmp = snapshot.data;
          // On loading.
          if (tmp == null) {
            return Center(child: CircularProgressIndicator());
            // On loaded.
          } else {
            // Convert snapshot into dart map.
            Map<String, dynamic> data = tmp.data() as Map<String, dynamic>;

            // Check for null input parameters and replace them with the newly loaded data.
            if (name == null) name = data['first-name'];
            if (bio == null) bio = data['bio'];
            if (house == null) house = data['house'];
            if (photoref == null) photoref = data['photo-ref'];

            // Tab controller switches between "edit" and "preview" mode.
            return DefaultTabController(
              initialIndex: 0,
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: CustomTheme.lightTheme.primaryColor,
                  title: Text("Your Profile"),
                  bottom: TabBar(
                    tabs: <Widget>[
                      Tab(
                        child: Text("Edit"),
                      ),
                      Tab(
                        child: Text("Preview"),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: <Widget>[
                    edit(),
                    preview(),
                  ],
                ),
              ),
            );
          }
        });
  }

  // Edit mode widget.
  Widget edit() {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
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
                    padding: const EdgeInsets.symmetric(horizontal: 64.0),
                    // FutureBuilder retrieves profile photo from Firebase Storage.
                    child: FutureBuilder(
                        future: DatabaseService(uid: widget.uid)
                            .getProfPic(photoref),
                        builder: (context,
                            AsyncSnapshot<ImageProvider<Object>> snapshot) {
                          // On error.
                          if (snapshot.hasError) {
                            return Text(snapshot.error.toString());
                            // During loading or success.
                          } else {
                            profpic = snapshot.data;
                            return profileImage();
                          }
                        }),
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
                            // On form validation, the newly entered field should be updated
                            // in the database. STILL NEED IMPLEMENTING - when a using uploads
                            // a new profile picture, go delete the old one in Firebase Storage.
                            await DatabaseService(uid: widget.uid)
                                .updateBio(bio);
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

  // Preview widget.
  Widget preview() {
    return Padding(
        padding: EdgeInsets.all(16.0),
        // FutureBuilder to retrieve profile photo from Firebase Storage.
        child: FutureBuilder(
            future: DatabaseService(uid: widget.uid).getProfPic(photoref),
            builder: (context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
              // On error.
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
                // On success.
              } else if (snapshot.connectionState == ConnectionState.done) {
                profpic = snapshot.data;
                ZestiUser previewUser = ZestiUser(
                    uid: "",
                    first: name.toString(),
                    last: "",
                    bio: bio.toString(),
                    dIdentity: "",
                    dInterest: "",
                    house: house.toString(),
                    age: 21,
                    profpic: profpic);
                return UserCard(userOnCard: previewUser, rec: true);
                // On loading.
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
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
    // Instantiate the image.
    ImageProvider<Object>? bgImage;

    // Update the image according to the dynamic imageFile.
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
