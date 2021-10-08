import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/profile.dart';
import 'package:zesti/views/home/love/love.dart';
import 'package:zesti/views/home/social/choose.dart';
import 'package:zesti/widgets/loading.dart';

// Home page of a logged in user.
class Home extends StatefulWidget {
  Home({
    Key? key,
  }) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void resetCallback() {
    setState(() {});
  }

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
                                        shape: BoxShape.circle),
                                  )),
                            ),
                          ],
                        ),
                        Text('Select a Mode',
                            style: CustomTheme.textTheme.headline1),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                child: Text('Love'),
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Love()),
                                  );
                                },
                              ),
                              TextButton(
                                child: Text('Social'),
                                onPressed: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Choose()),
                                  );
                                },
                              ),
                            ]),
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
}
