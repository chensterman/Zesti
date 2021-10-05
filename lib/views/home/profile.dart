import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/home.dart';
import 'package:zesti/widgets/previewcard.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for the profile editing page.
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
  String? year;
  String? dIdentity;
  String? dInterest;
  String? photoref;
  String zestKey = "";
  dynamic profpic;

  // List of Harvard houses
  List<String> _houseList = [
    'Apley Court',
    'Canaday',
    'Grays',
    'Greenough',
    'Hollis',
    'Holworthy',
    'Hurlbut',
    'Lionel',
    'Mower',
    'Massachusetts Hall',
    'Mathews',
    'Pennypacker',
    'Stoughton',
    'Straus',
    'Thayer',
    'Weld',
    'Wigglesworth',
    'Adams',
    'Cabot',
    'Currier',
    'Dunster',
    'Eliot',
    'Kirkland',
    'Leverett',
    'Lowell',
    'Mather',
    'Pfohozeimer',
    'Quincy',
    'Winthrop',
  ];

  // List of years
  List<String> _yearList = [
    '\'22',
    '\'23',
    '\'24',
    '\'25',
  ];

  // List of identities
  List<String> _identityList = [
    'Man',
    'Woman',
    'Non-binary',
  ];

  // List of interests
  List<String> _interestList = [
    'Men',
    'Women',
    'Everyone',
  ];

  // Stream to retrieve user profile information (initialized during initState).
  Stream<DocumentSnapshot>? profileInfo;

  @override
  void initState() {
    profileInfo = DatabaseService(uid: widget.uid).getEditProfileInfo();
    super.initState();
  }

  void houseCallback(String? val) {
    setState(() {
      house = val;
    });
  }

  void yearCallback(String? val) {
    setState(() {
      year = val;
    });
  }

  void dIdentityCallback(String? val) {
    setState(() {
      dIdentity = val;
    });
  }

  void dInterestCallback(String? val) {
    setState(() {
      dIdentity = val;
    });
  }

  void profpicCallback(dynamic val) {
    setState(() {
      profpic = val;
    });
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
            if (year == null) year = data['year'];
            // Dating identity is a special case where the lowercase word (as stored in Firestore) must have its first letter put in uppercase for UI purposes.
            if (dIdentity == null) {
              String tmp = data['dating-identity'];
              dIdentity = "${tmp[0].toUpperCase()}${tmp.substring(1)}";
            }
            // Dating interest is a special case where the singular word (as stored in Firestore) must be turned into plural for UI purposes.
            if (dInterest == null) {
              String tmp = data['dating-interest'];
              if (tmp == 'man') {
                dInterest = 'Men';
              } else if (tmp == 'woman') {
                dInterest = 'Women';
              } else if (tmp == 'everyone') {
                dInterest = "${tmp[0].toUpperCase()}${tmp.substring(1)}";
              }
            }
            if (photoref == null) photoref = data['photo-ref'];
            zestKey = data['zest-key'];

            // Tab controller switches between "edit" and "preview" mode.
            TabBar tabBar = TabBar(
              automaticIndicatorColorAdjustment: false,
              indicatorColor: CustomTheme.reallyBrightOrange,
              tabs: <Widget>[
                Tab(
                  child: Text("Edit",
                      style: TextStyle(color: CustomTheme.reallyBrightOrange)),
                ),
                Tab(
                  child: Text("Preview",
                      style: TextStyle(color: CustomTheme.reallyBrightOrange)),
                ),
              ],
            );
            return DefaultTabController(
              initialIndex: 0,
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: CustomTheme.reallyBrightOrange,
                  title: Text("Your Profile"),
                  bottom: PreferredSize(
                    preferredSize: tabBar.preferredSize,
                    child: ColoredBox(
                      color: Colors.white,
                      child: tabBar,
                    ),
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
    return Scaffold(
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: Container(
            child: Form(
              key: _formKey,
              child: Center(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  profpic == null
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 64.0),
                                          // FutureBuilder retrieves profile photo from Firebase Storage.
                                          child: FutureBuilder(
                                              future: DatabaseService(
                                                      uid: widget.uid)
                                                  .getPhoto(photoref),
                                              builder: (context,
                                                  AsyncSnapshot<
                                                          ImageProvider<Object>>
                                                      snapshot) {
                                                // On error.
                                                if (snapshot.hasError) {
                                                  return Text(snapshot.error
                                                      .toString());
                                                  // During loading or success.
                                                } else {
                                                  profpic = snapshot.data;
                                                  return ImageUpdate(
                                                      callback: profpicCallback,
                                                      profpic: profpic);
                                                }
                                              }),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 64.0),
                                          // FutureBuilder retrieves profile photo from Firebase Storage.
                                          child: ImageUpdate(
                                              callback: profpicCallback,
                                              profpic: profpic),
                                        ),
                                  SizedBox(height: 20.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Center(
                                        child: Text(
                                      "Your ZestKey:",
                                      style: CustomTheme.textTheme.headline2,
                                    )),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Center(
                                        child: Text(
                                      zestKey,
                                      style: CustomTheme.textTheme.headline1,
                                    )),
                                  ),
                                  SizedBox(height: 20.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "Bio:",
                                      style: CustomTheme.textTheme.headline2,
                                    ),
                                  ),
                                  TextFormField(
                                    initialValue: bio,
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
                                  ),
                                  SizedBox(height: 20.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "House:",
                                      style: CustomTheme.textTheme.headline2,
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  DropDownField(
                                      callback: houseCallback,
                                      initValue: house,
                                      houseList: _houseList),
                                  SizedBox(height: 20.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "Year:",
                                      style: CustomTheme.textTheme.headline2,
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  DropDownField(
                                      callback: yearCallback,
                                      initValue: year,
                                      houseList: _yearList),
                                  SizedBox(height: 20.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "Identity:",
                                      style: CustomTheme.textTheme.headline2,
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  DropDownField(
                                      callback: dIdentityCallback,
                                      initValue: dIdentity,
                                      houseList: _identityList),
                                  SizedBox(height: 20.0),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: Text(
                                      "Interest:",
                                      style: CustomTheme.textTheme.headline2,
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  DropDownField(
                                      callback: dInterestCallback,
                                      initValue: dInterest,
                                      houseList: _interestList),
                                  SizedBox(height: 20.0),
                                  RoundedButton(
                                      text: 'Update',
                                      onPressed: () async {
                                        // Check for any null (blank) user input and validate the form.
                                        if (bio != null &&
                                            house != null &&
                                            year != null &&
                                            dIdentity != null &&
                                            dInterest != null &&
                                            profpic != null &&
                                            _formKey.currentState!.validate()) {
                                          // Update all info in Firestore.
                                          await DatabaseService(uid: widget.uid)
                                              .updateBio(bio!);
                                          await DatabaseService(uid: widget.uid)
                                              .updateHouse(house!);
                                          await DatabaseService(uid: widget.uid)
                                              .updateYear(year!);
                                          // Take on dating identity/interest special cases.
                                          await DatabaseService(uid: widget.uid)
                                              .updateDatingIdentity(
                                                  dIdentity!.toLowerCase());
                                          String tmp = "";
                                          if (dInterest == "Men") {
                                            tmp = "man";
                                          } else if (dInterest == "Women") {
                                            tmp = "woman";
                                          } else if (dInterest == "Everyone") {
                                            tmp = "everyone";
                                          }
                                          await DatabaseService(uid: widget.uid)
                                              .updateDatingInterest(tmp);
                                          await DatabaseService(uid: widget.uid)
                                              .updatePhoto(profpic);
                                          // Navigate back to home page.
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Home()),
                                          );
                                        }
                                      }),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Preview widget.
  Widget preview() {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder(
        future: DatabaseService(uid: widget.uid).getPhoto(photoref),
        builder: (context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
          // On error.
          if (snapshot.hasError) {
            return Text(snapshot.error.toString());
            // During loading or success.
          } else if (snapshot.connectionState == ConnectionState.done) {
            ZestiUser previewUser = ZestiUser(
                uid: "",
                first: name.toString(),
                last: "",
                bio: bio.toString(),
                dIdentity: "",
                dInterest: "",
                house: house.toString(),
                age: 21,
                photoURL: "",
                year: "",
                profPic: snapshot.data!,
                zestKey: "");
            return Scaffold(
              body: Container(
                decoration: CustomTheme.mode,
                child: Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        vertical: size.height * CustomTheme.paddingMultiplier,
                        horizontal: size.width * CustomTheme.paddingMultiplier),
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      // FutureBuilder to retrieve profile photo from Firebase Storage.
                      child: PreviewCard(userOnCard: previewUser, rec: true),
                    ),
                  ),
                ),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
}
