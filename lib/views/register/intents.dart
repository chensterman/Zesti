import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/register/house.dart';
import 'package:zesti/widgets/loading.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for interest form
class Intents extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
      ),
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: Container(
            child: Form(
              child: Center(
                child: ListView(shrinkWrap: true, children: <Widget>[
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
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    "What are you looking for?",
                                    style: CustomTheme.textTheme.headline2,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                  text: 'Friendship',
                                  onPressed: () async {
                                    ZestiLoadingAsync().show(context);
                                    await DatabaseService(uid: user!.uid)
                                        .updateDatingIntent("friendship");
                                    ZestiLoadingAsync().dismiss();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => House()),
                                    );
                                  },
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                  text: 'Love',
                                  onPressed: () async {
                                    if (user == null) {
                                      print("Error");
                                    } else {
                                      ZestiLoadingAsync().show(context);
                                      await DatabaseService(uid: user.uid)
                                          .updateDatingIntent("love");
                                      ZestiLoadingAsync().dismiss();
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => House()),
                                    );
                                  },
                                ),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                  text: 'Both',
                                  onPressed: () async {
                                    if (user == null) {
                                      print("Error");
                                    } else {
                                      ZestiLoadingAsync().show(context);
                                      await DatabaseService(uid: user.uid)
                                          .updateDatingInterest("both");
                                      ZestiLoadingAsync().dismiss();
                                    }
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => House()),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: size.height * 0.3,
                                  child: SvgPicture.asset("assets/phone.svg",
                                      semanticsLabel: "Interest"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
