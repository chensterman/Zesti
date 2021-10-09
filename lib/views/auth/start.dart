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
              child: ZestiLogo(),
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
    duration: const Duration(seconds: 5),
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
