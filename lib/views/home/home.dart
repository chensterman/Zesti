import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/profile.dart';
import 'package:zesti/views/home/love/love.dart';
import 'package:zesti/views/home/social/choose.dart';
import 'package:zesti/widgets/loading.dart';
import 'package:zesti/services/notifications.dart';
import 'package:zesti/views/home/deals.dart';

// Home page of a logged in user.
class Home extends StatefulWidget {
  Home({
    Key? key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // This callback function resets the state of this homepage
  // It is called in EditProfile for when a user updates their info
  void resetCallback() {
    setState(() {});
  }

  String notificationTitle = 'No Title';
  String notificationBody = 'No Body';
  String notificationData = 'No Data';

  @override
  void initState() {
    final notificationService = NotificationService();
    notificationService.setNotifications();

    notificationService.streamCtlr.stream.listen(_changeData);
    notificationService.bodyCtlr.stream.listen(_changeBody);
    notificationService.titleCtlr.stream.listen(_changeTitle);
    super.initState();

    NotificationService().handlePermissions();
    NotificationService().handleToken();
  }

  _changeData(String msg) => setState(() => notificationData = msg);
  _changeBody(String msg) => setState(() => notificationBody = msg);
  _changeTitle(String msg) => setState(() => notificationTitle = msg);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.1, horizontal: size.width * 0.1),
        decoration: CustomTheme.standard,
        child: Center(
          child: FutureBuilder(
              future: DatabaseService(uid: user!.uid).getUserInfo(
                  DatabaseService(uid: user.uid).userCollection.doc(user.uid)),
              builder: (context, AsyncSnapshot<ZestiUser> snapshot) {
                // On error.
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                  // On success.
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Looking good, " + snapshot.data!.first + "!",
                            style: CustomTheme.textTheme.headline1),
                        Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                      offset: Offset(2.0, 2.0),
                                      blurRadius: 5,
                                      color: Colors.grey.shade700,
                                      spreadRadius: 5)
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 80.0,
                                backgroundImage: snapshot.data!.profPic,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              right: 1.0,
                              child: InkWell(
                                  onTap: () {
                                    // Navigate to EditProfile page
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EditProfile(
                                              callback: resetCallback,
                                              user: snapshot.data!)),
                                    );
                                  },
                                  child: Container(
                                    child: Icon(
                                      Icons.account_circle,
                                      color: CustomTheme.reallyBrightOrange,
                                      size: 36.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        Text('Select a Mode',
                            style: CustomTheme.textTheme.headline1),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                  onTap: () async {
                                    // Navigate to solo matching
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Love()),
                                    );
                                  },
                                  child: Column(
                                    children: [
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
                                                color: Colors.grey.shade700,
                                                spreadRadius: -2)
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 100.0,
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Solo",
                                                    style: CustomTheme
                                                        .textTheme.headline3))),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: Offset(3.0, 3.0),
                                                blurRadius: 5,
                                                color: Colors.grey.shade700,
                                                spreadRadius: 3)
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                              InkWell(
                                  onTap: () async {
                                    // Navigate to group matching
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Choose()),
                                    );
                                  },
                                  child: Column(
                                    children: [
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
                                                color: Colors.grey.shade700,
                                                spreadRadius: -2)
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 100.0,
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(
                                            child: Align(
                                                alignment: Alignment.center,
                                                child: Text("Group",
                                                    style: CustomTheme
                                                        .textTheme.headline3))),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                                offset: Offset(3.0, 3.0),
                                                blurRadius: 5,
                                                color: Colors.grey.shade700,
                                                spreadRadius: 3)
                                          ],
                                        ),
                                      ),
                                    ],
                                  )),
                            ]),
                            Container(
                              child: jefes_first_btn(context, user.uid),
                            )

                      ]);
                  // During loading.
                } else {
                  return ZestiLoading();
                }
              }),
        ),
      ),
    );
  }

  // Card that displays a specific partner deal.
  Widget jefes_first_btn(BuildContext context,  String uid) {
    final user = Provider.of<User?>(context);
    Size size = MediaQuery.of(context).size;
    ImageProvider<Object> partnerPic = AssetImage("assets/profile.jpg");
    double containerHeight = size.height * .20;
    return FutureBuilder(
      future: DatabaseService(uid: user!.uid).userCollection.doc(user.uid).collection('metrics').doc('eljefes-first').get(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.data!['count'] == 0) {
          return Container(
        height: containerHeight,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: EdgeInsets.all(16.0),
          child: InkWell(
            splashColor: CustomTheme.reallyBrightOrange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => Redeem(
                        partnerid: "eljefes-first",
                        partnerPic: partnerPic,
                        vendor: "El Jefe's Taqueria",
                        description: "One time free chips and guac for new users!",
                        uid: uid)),
              );
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  FutureBuilder(
                      future: DatabaseService(uid: user.uid).getPhoto("partnerpics/eljefes.jpg"),
                      builder:
                          (context, AsyncSnapshot<ImageProvider<Object>> snapshot) {
                        // On error.
                        if (snapshot.hasError) {
                          return Text(snapshot.hasError.toString());
                          // On success.
                        } else if (snapshot.connectionState ==
                            ConnectionState.done) {
                          partnerPic = snapshot.data!;
                          return CircleAvatar(
                            radius: containerHeight *.12,
                            backgroundImage: snapshot.data!,
                            backgroundColor: Colors.white,
                          );
                          // On loading, return an empty container.
                        } else {
                          return ZestiLoading();
                        }
                      }),
                  SizedBox(height: containerHeight * .05),
                  Text("El Jefe's Taqueria",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.orange[900], fontSize: 15.0)),
                  SizedBox(height: containerHeight * .1),
                  Text("Click here to redeem your one time free chips and guac for new users!",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.0)),
                ],
              ),
            ),
          ),
        ),
    );
        }
        else {
          return SizedBox.shrink();
        }
      } );
  }


}


