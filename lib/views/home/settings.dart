import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/widgets/formwidgets.dart';
import 'package:zesti/views/auth/start.dart';

// Widget for the profile editing page.
class AccountSettings extends StatelessWidget {
  AccountSettings({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // StreamBuilder to display profile info stream.
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text("Your Profile"),
      ),
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: Container(
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
                                RoundedButton(
                                    text: 'Logout',
                                    onPressed: () async {
                                      await AuthService().signOut();
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                    }),
                                SizedBox(height: 20.0),
                                RoundedButton(
                                    text: 'Delete Account',
                                    onPressed: () async {}),
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
    );
  }
}
