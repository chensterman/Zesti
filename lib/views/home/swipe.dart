import 'package:flutter/material.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:provider/provider.dart';

class Swipe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test"),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                primary: CustomTheme.lightTheme.primaryColor,
                padding: const EdgeInsets.only(
                    left: 30, top: 10, right: 30, bottom: 10),
                shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(30.0))),
            onPressed: () {
              AuthService().signOut();
            },
            child: Text("Logout"),
          )
        ],
      ),
    );
  }
}
