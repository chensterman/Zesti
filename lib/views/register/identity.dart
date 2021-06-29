import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/register/interest.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Widget for the identity form
class Identity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final user = Provider.of<User?>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
      ),
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
                SizedBox(height: 20.0),
                RoundedButton(
                  text: 'Man',
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
                ),
                SizedBox(height: 20.0),
                RoundedButton(
                  text: 'Woman',
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
                ),
                SizedBox(height: 20.0),
                RoundedButton(
                  text: 'Non-binary',
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
                ),
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
