import 'dart:io';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/previewcard.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for the profile editing page.
class EditProfile extends StatefulWidget {
  final Function callback;
  final ZestiUser user;
  EditProfile({
    Key? key,
    required this.callback,
    required this.user,
  }) : super(key: key);

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  // Form widget key.
  final _formKey = GlobalKey<FormState>();

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

  @override
  void initState() {
    super.initState();
    name = widget.user.first;
    bio = widget.user.bio;
    house = widget.user.house;
    year = widget.user.year;
    String tmp = widget.user.dIdentity;
    dIdentity = "${tmp[0].toUpperCase()}${tmp.substring(1)}";
    tmp = widget.user.dInterest;
    if (tmp == 'man') {
      dInterest = 'Men';
    } else if (tmp == 'woman') {
      dInterest = 'Women';
    } else if (tmp == 'everyone') {
      dInterest = "${tmp[0].toUpperCase()}${tmp.substring(1)}";
    }
    photoref = widget.user.photoURL;
    zestKey = widget.user.zestKey;
    profpic = widget.user.profPic;
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

  void profpicCallback(File? val) {
    setState(() {
      profpic = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    // StreamBuilder to display profile info stream.
    TabBar tabBar = TabBar(
      automaticIndicatorColorAdjustment: false,
      indicatorColor: CustomTheme.reallyBrightOrange,
      tabs: <Widget>[
        Tab(
          child: Text("Edit", style: CustomTheme.textTheme.headline3),
        ),
        Tab(
          child: Text("Preview", style: CustomTheme.textTheme.headline3),
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
          actions: [
            InkWell(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) => accountSettings(context));
                },
                child: Container(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(
                    Icons.settings,
                    color: CustomTheme.reallyBrightOrange,
                    size: 26.0,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                )),
            SizedBox(width: 20.0),
          ],
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
                                  Padding(
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
                                  Center(
                                      child: RoundedButton(
                                          text: 'Update',
                                          onPressed: () async {
                                            // Check for any null (blank) user input and validate the form.
                                            if (bio != null &&
                                                house != null &&
                                                year != null &&
                                                dIdentity != null &&
                                                dInterest != null &&
                                                _formKey.currentState!
                                                    .validate()) {
                                              // Update all info in Firestore.
                                              await DatabaseService(
                                                      uid: widget.user.uid)
                                                  .updateBio(bio!);
                                              await DatabaseService(
                                                      uid: widget.user.uid)
                                                  .updateHouse(house!);
                                              await DatabaseService(
                                                      uid: widget.user.uid)
                                                  .updateYear(year!);
                                              // Take on dating identity/interest special cases.
                                              await DatabaseService(
                                                      uid: widget.user.uid)
                                                  .updateDatingIdentity(
                                                      dIdentity!.toLowerCase());
                                              String tmp = "";
                                              if (dInterest == "Men") {
                                                tmp = "man";
                                              } else if (dInterest == "Women") {
                                                tmp = "woman";
                                              } else if (dInterest ==
                                                  "Everyone") {
                                                tmp = "everyone";
                                              }
                                              await DatabaseService(
                                                      uid: widget.user.uid)
                                                  .updateDatingInterest(tmp);
                                              if (profpic is File ||
                                                  profpic == null) {
                                                await DatabaseService(
                                                        uid: widget.user.uid)
                                                    .updatePhoto(profpic);
                                              }
                                              // Navigate back to home page.
                                              Navigator.of(context).pop();
                                              widget.callback();
                                              showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      updateConfirmDialog(
                                                          context));
                                            }
                                          })),
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
    dynamic tmp;
    if (profpic == null) {
      tmp = AssetImage("assets/profile.jpg");
    } else if (profpic is File) {
      tmp = FileImage(profpic);
    } else {
      tmp = profpic;
    }
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
        year: year.toString(),
        profPic: tmp,
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
  }

  Widget accountSettings(BuildContext context) {
    final user = Provider.of<User?>(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Center(child: Text("Account Settings")),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 32.0),
          child: Column(
            children: [
              RoundedButton(
                  text: 'Reset Password',
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            resetConfirmDialog(context, user!.email!));
                  }),
              SizedBox(height: 20.0),
              RoundedButton(
                  text: 'Delete Account',
                  onPressed: () async {
                    showDialog(
                        context: context,
                        builder: (context) => deleteConfirmDialog(context));
                  }),
              SizedBox(height: 50.0),
              RoundedButton(
                  text: 'Logout',
                  onPressed: () async {
                    await AuthService().signOut();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget resetConfirmDialog(BuildContext context, String email) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text("Send a password reset email to " + email + "?"),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: SvgPicture.asset("assets/name.svg"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Yes", style: CustomTheme.textTheme.headline1),
          onPressed: () async {
            await AuthService().resetPassword(email);
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("No", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget deleteConfirmDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Are you sure? All of your info will be erased."),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: SvgPicture.asset("assets/warning.svg"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Yes", style: CustomTheme.textTheme.headline1),
          onPressed: () async {
            await AuthService().deleteUser();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
        TextButton(
          child: Text("No", style: CustomTheme.textTheme.headline2),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget updateConfirmDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Text("Your profile has been updated."),
      content: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
          height: 150.0,
          child: SvgPicture.asset("assets/name.svg"),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text("Ok", style: CustomTheme.textTheme.headline3),
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
