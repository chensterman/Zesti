import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/register/interest.dart';

class Identity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      body: Center(
        child: Container(
          width: size.width * CustomTheme.containerWidth,
          padding: const EdgeInsets.all(20),
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "How do you identify?",
                    style: CustomTheme.lightTheme.textTheme.headline1,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: CustomTheme.lightTheme.primaryColor,
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, right: 30, bottom: 10),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                      onPressed: () async {
                        if (user == null) {
                          print("Error");
                        } else {
                          await DatabaseService(uid: user.uid)
                              .updateDatingIdentity("man");
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Interest()),
                        );
                      },
                      child: Text("Man"),
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: CustomTheme.lightTheme.primaryColor,
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, right: 30, bottom: 10),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                      onPressed: () async {
                        if (user == null) {
                          print("Error");
                        } else {
                          await DatabaseService(uid: user.uid)
                              .updateDatingIdentity("woman");
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Interest()),
                        );
                      },
                      child: Text("Woman"),
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: CustomTheme.lightTheme.primaryColor,
                          padding: const EdgeInsets.only(
                              left: 30, top: 10, right: 30, bottom: 10),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(30.0))),
                      onPressed: () async {
                        if (user == null) {
                          print("Error");
                        } else {
                          await DatabaseService(uid: user.uid)
                              .updateDatingIdentity("non-binary");
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Interest()),
                        );
                      },
                      child: Text("Non-binary"),
                    )),
                SizedBox(
                  width: double.infinity,
                  height: size.height * 0.3,
                  child: SvgPicture.asset("assets/phone.svg",
                      semanticsLabel: "Identity"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
