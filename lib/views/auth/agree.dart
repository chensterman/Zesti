import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zesti/views/auth/signup.dart';
import 'package:zesti/widgets/formwidgets.dart';

// Starting page widget
class Agree extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: CustomTheme.standard,
        child: Center(
          child: ListView(shrinkWrap: true, children: <Widget>[
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
                    SizedBox(
                      width: double.infinity,
                      height: size.height * 0.3,
                      child: SvgPicture.asset("assets/tos.svg",
                          semanticsLabel: "TOS"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Text(
                        "In order to continue, please confirm that you have read and agree to both Zesti's",
                        style: CustomTheme.textTheme.headline2,
                      ),
                    ),
                    SizedBox(height: 20.0),
                    InkWell(
                        child: Text('End-User License Agreement',
                            style: CustomTheme.textTheme.headline1,
                            textAlign: TextAlign.center),
                        onTap: () => launch(
                            'https://docs.google.com/document/d/1twAtFqXKXUEIBR0MxwT5UTRtL0CyIJr9EPPNyY_nhLU/edit?usp=sharing')),
                    SizedBox(height: 10.0),
                    InkWell(
                        child: Text('Privacy Policy',
                            style: CustomTheme.textTheme.headline1),
                        onTap: () => launch(
                            'https://docs.google.com/document/d/1EfoH1UT2w8buLRmbKUfwQKzv8OYUFyayo5ZDCk0FfU8/edit?usp=sharing')),
                    SizedBox(height: 40.0),
                    Row(
                      children: [],
                    ),
                    RoundedButton(
                      text: 'Confirm',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// This is the stateful widget that the main application instantiates.
class ZestiLogo extends StatefulWidget {
  const ZestiLogo({Key? key}) : super(key: key);

  @override
  State<ZestiLogo> createState() => _ZestiLogoState();
}

/// This is the private State class that goes with MyStatefulWidget.
/// AnimationControllers can be created with `vsync: this` because of TickerProviderStateMixin.
class _ZestiLogoState extends State<ZestiLogo> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutSine,
  );

  late final Animation<Offset> _offsetAnimation = Tween<Offset>(
    begin: Offset(0.0, -0.1),
    end: Offset(0.0, 0.1),
  ).animate(_animation);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Center(
      child: SlideTransition(
        position: _offsetAnimation,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SizedBox(
            width: size.width * 0.8,
            height: size.height * 0.4,
            child:
                SvgPicture.asset("assets/zesti.svg", semanticsLabel: "Zesti"),
          ),
        ),
      ),
    );
  }
}
