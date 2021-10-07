import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/start.dart';
import 'package:zesti/views/home/profile.dart';
import 'package:zesti/views/home/love/love.dart';
import 'package:zesti/views/home/social/choose.dart';

// Home page of a logged in user.
class Home extends StatelessWidget {
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
                            style: CustomTheme.textTheme.headline4),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 80.0,
                              backgroundImage: snapshot.data!.profPic,
                              backgroundColor: Colors.white,
                            ),
                            Positioned(
                              bottom: 0.0,
                              right: 1.0,
                              child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              Profile(uid: user.uid)),
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
                            style: CustomTheme.textTheme.headline4),
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
                  return CircularProgressIndicator();
                }
              }),
        ),
      ),
    );
  }
}
