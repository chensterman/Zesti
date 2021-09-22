import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/home.dart';
import 'package:zesti/views/home/social/recommendations.dart';
import 'package:zesti/views/home/social/requests.dart';
import 'package:zesti/views/home/social/group.dart';
import 'package:zesti/views/home/social/matches.dart';

// Widget containing swiping, profile management, and matches
class Social extends StatefulWidget {
  final String gid;
  Social({Key? key, required this.gid}) : super(key: key);

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  // Firebase storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Inital widget to display
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      Group(gid: widget.gid),
      Recommendations(gid: widget.gid),
      Requests(gid: widget.gid),
      Matches(gid: widget.gid),
    ];

    // Main page widget (contains nav bar pages as well)
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Home()),
          ),
        ),
        backgroundColor: CustomTheme.reallyBrightOrange,
        title: Text("Zesti Social"),
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
          Icon(Icons.groups),
          Icon(Icons.hourglass_top),
          Icon(Icons.mood),
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
