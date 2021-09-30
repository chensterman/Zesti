// Dart file container various alert dialogs used across the app
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/theme/theme.dart';

Widget ageDialog(context) {
  return AlertDialog(
    title: const Text('You must be 18 years or older to proceed.'),
    content: SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        height: 150.0,
        child:
            SvgPicture.asset("assets/warning.svg", semanticsLabel: "Warning"),
      ),
    ),
    actions: <Widget>[
      TextButton(
        child: Text("Ok", style: CustomTheme.textTheme.headline2),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ],
  );
}

class RequestDialog extends StatelessWidget {
  RequestDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Test"),
    );
  }
}

class MatchDialog extends StatelessWidget {
  MatchDialog({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog();
  }
}
