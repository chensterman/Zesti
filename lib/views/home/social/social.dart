import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:provider/provider.dart';

// Widget containing swiping, profile management, and matches
class Social extends StatefulWidget {
  Social({Key? key}) : super(key: key);

  @override
  _SocialState createState() => _SocialState();
}

class _SocialState extends State<Social> {
  // Firebase storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Inital widget to display
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return Text('User Error');
    }

    Size size = MediaQuery.of(context).size;
    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      Text('Your Group'),
      Text('Group Recommendations'),
      Text('Incoming Requests'),
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
