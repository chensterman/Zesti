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
        padding: EdgeInsets.symmetric(
            vertical: size.height * 0.1, horizontal: size.width * 0.1),
        decoration: BoxDecoration(
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,

            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.3, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              CustomTheme.lightTheme.primaryColor,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: double.infinity,
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
