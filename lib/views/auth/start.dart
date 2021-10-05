import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/auth/signup.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Starting page widget
class Start extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: CustomTheme.standard,
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: size.width * 0.8,
              height: size.height * 0.4,
              child:
                  SvgPicture.asset("assets/zesti.svg", semanticsLabel: "Zesti"),
            ),
            RoundedButton(
              text: 'Get Started',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignUp()),
                );
              },
            )
          ]),
        ),
      ),
    );
  }
}
