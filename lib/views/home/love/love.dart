import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      body: Center(
        child: _widgetSet.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: size.width * 0.08,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_top), label: "Match Recommendations"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: "Match Requests"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble), label: "Matches"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: CustomTheme.lightTheme.primaryColor,
        unselectedItemColor: Colors.grey,
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
