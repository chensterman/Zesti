import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/start.dart';
import 'package:zesti/views/home/profile.dart';
import 'package:zesti/views/home/love/love.dart';
import 'package:zesti/views/home/social/choose.dart';

// Starting page widget
class Home extends StatelessWidget {
  // This widget is the root of your application.
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
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Looking good, asdf!',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        color: Colors.white)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        child: Text('Edit Profile'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Profile(uid: user!.uid)),
                          );
                        },
                      ),
                      TextButton(
                        child: Text('Logout'),
                        onPressed: () async {
                          await AuthService().signOut();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Start()),
                          );
                        },
                      )
                    ]),
                Text('Select a Mode',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32.0,
                        color: Colors.white)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        child: Text('Love'),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Love()),
                          );
                        },
                      ),
                      TextButton(
                        child: Text('Social'),
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Choose()),
                          );
                        },
                      ),
                    ]),
              ]),
        ),
      ),
    );
  }
}
