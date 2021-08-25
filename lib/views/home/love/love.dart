import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home//love/matches.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestiuser.dart';

// Widget containing swiping, profile management, and matches
class Love extends StatefulWidget {
  Love({Key? key}) : super(key: key);

  @override
  _LoveState createState() => _LoveState();
}

class _LoveState extends State<Love> {
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
      Recommendations(),
      Requests(),
      Matches(uid: user.uid),
    ];

    // Main page widget (contains nav bar pages as well)
    return Scaffold(
      appBar: AppBar(
        backgroundColor: CustomTheme.lightTheme.primaryColor,
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
              icon: Icon(Icons.mood), label: "Match Requests"),
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

// Widget containing swiping, profile management, and matches
class Recommendations extends StatefulWidget {
  Recommendations({Key? key}) : super(key: key);

  @override
  _RecommendationsState createState() => _RecommendationsState();
}

class _RecommendationsState extends State<Recommendations> {
  List<UserCard1> widgetList = [];

  ZestiUser user1 = ZestiUser(
    uid: '1',
    first: 'Gabby',
    last: 'Thomas',
    bio: 'I run fast.',
    dIdentity: 'woman',
    dInterest: 'man',
    house: 'Quincy',
    age: 24,
    profpic: AssetImage('assets/profile.jpg'),
  );

  ZestiUser user2 = ZestiUser(
    uid: '2',
    first: 'Scarlett',
    last: 'Johansson',
    bio: 'I played in Black Widow.',
    dIdentity: 'woman',
    dInterest: 'man',
    house: 'Dunster',
    age: 36,
    profpic: AssetImage('assets/profile.jpg'),
  );

  ZestiUser user3 = ZestiUser(
    uid: '3',
    first: 'Elle',
    last: 'Woods',
    bio: 'I am very cool.',
    dIdentity: 'woman',
    dInterest: 'man',
    house: 'Pfoho',
    age: 22,
    profpic: AssetImage('assets/profile.jpg'),
  );

  @override
  Widget build(BuildContext context) {
    widgetList.add(UserCard1(user: user1, rec: true));
    widgetList.add(UserCard1(user: user2, rec: true));
    widgetList.add(UserCard1(user: user3, rec: true));

    return Container(
      child: ListView.separated(
          padding: EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Center(
                  child: Text('RECOMMENDATIONS',
                      style: TextStyle(color: Colors.orange[900])));
            }
            return widgetList[index - 1];
          },
          separatorBuilder: (context, index) => SizedBox(height: 16.0),
          itemCount: widgetList.length + 1),
    );
  }
}

// Widget containing swiping, profile management, and matches
class Requests extends StatefulWidget {
  Requests({Key? key}) : super(key: key);

  @override
  _RequestsState createState() => _RequestsState();
}

class _RequestsState extends State<Requests> {
  List<UserCard1> widgetList = [];

  ZestiUser user1 = ZestiUser(
    uid: '1',
    first: 'Gabby',
    last: 'Thomas',
    bio: 'I run fast.',
    dIdentity: 'woman',
    dInterest: 'man',
    house: 'Quincy',
    age: 24,
    profpic: AssetImage('assets/profile.jpg'),
  );

  ZestiUser user2 = ZestiUser(
    uid: '2',
    first: 'Scarlett',
    last: 'Johansson',
    bio: 'I played in Black Widow.',
    dIdentity: 'woman',
    dInterest: 'man',
    house: 'Dunster',
    age: 36,
    profpic: AssetImage('assets/profile.jpg'),
  );

  ZestiUser user3 = ZestiUser(
    uid: '3',
    first: 'Elle',
    last: 'Woods',
    bio: 'I am very cool.',
    dIdentity: 'woman',
    dInterest: 'man',
    house: 'Pfoho',
    age: 22,
    profpic: AssetImage('assets/profile.jpg'),
  );

  @override
  Widget build(BuildContext context) {
    widgetList.add(UserCard1(user: user1, rec: false));
    widgetList.add(UserCard1(user: user2, rec: false));
    widgetList.add(UserCard1(user: user3, rec: false));

    return Container(
      child: ListView.separated(
          padding: EdgeInsets.all(16.0),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Center(
                  child: Text('INCOMING REQUESTS',
                      style: TextStyle(color: Colors.orange[900])));
            }
            return widgetList[index - 1];
          },
          separatorBuilder: (context, index) => SizedBox(height: 16.0),
          itemCount: widgetList.length + 1),
    );
  }
}
