import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:provider/provider.dart';
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

    Size size = MediaQuery.of(context).size;
    // Widget list for bottom nav bar.
    final List<Widget> _widgetSet = <Widget>[
      Recommendations(uid: user!.uid),
      Requests(uid: user.uid),
      Matches(uid: user.uid),
    ];

    // Main page widget (contains nav bar pages as well).
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Zesti Love"),
      ),
      body: Container(
        decoration: BoxDecoration(
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.2, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              CustomTheme.lightTheme.cardColor,
              CustomTheme.lightTheme.primaryColor,
            ],
          ),
        ),
        child: Center(
          child: _widgetSet.elementAt(_selectedIndex),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
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
