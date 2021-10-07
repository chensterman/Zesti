import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/love/matches.dart';
import 'package:zesti/views/home/love/recommendations.dart';
import 'package:zesti/views/home/love/requests.dart';

// Widget containing swiping, profile management, and matches.
class Love extends StatefulWidget {
  Love({Key? key}) : super(key: key);

  @override
  _LoveState createState() => _LoveState();
}

class _LoveState extends State<Love> {
  // Inital widget to display.
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    // Widget list for bottom nav bar.
    final List<Widget> _widgetSet = <Widget>[
      Recommendations(uid: user!.uid),
      Requests(uid: user.uid),
      Matches(uid: user.uid),
    ];

    // Main page widget (contains nav bar pages as well).
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: SizedBox(
          height: 50.0,
          child: SvgPicture.asset(
            "assets/zesti.svg",
            alignment: Alignment.centerLeft,
          ),
        ),
      ),
      body: Container(
        decoration: CustomTheme.mode,
        child: Center(
          child: _widgetSet.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: CustomTheme.reallyBrightOrange,
        items: <Widget>[
          Icon(Icons.hourglass_top),
          Icon(Icons.favorite),
          Icon(Icons.chat_bubble),
        ],
        onTap: _onItemTapped,
      ),
    );
  }

  // Change selected index for onTap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
