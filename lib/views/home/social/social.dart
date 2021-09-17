import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/social/recommendations.dart';
import 'package:zesti/views/home/social/requests.dart';
import 'package:zesti/views/home/social/group.dart';

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
    Size size = MediaQuery.of(context).size;
    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      Group(gid: widget.gid),
      Recommendations(gid: widget.gid),
      Requests(gid: widget.gid),
      Text('Matches'),
    ];

    // Main page widget (contains nav bar pages as well)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        title: Text("Zesti Social"),
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
              icon: Icon(Icons.groups), label: "Your Group"),
          BottomNavigationBarItem(
              icon: Icon(Icons.hourglass_top), label: "Group Recommendations"),
          BottomNavigationBarItem(
              icon: Icon(Icons.mood), label: "Incoming Requests"),
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
