import 'dart:convert';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:zesti/services/auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:zesti/test/dummyusers.dart';
import 'package:zesti/test/user.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:zesti/providers/cardposition.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Iniital widget to display
  int _selectedIndex = 1;

  // Dummy users (for testing purposes - no database interaction)
  final List<User> users = dummyUsers;

  @override
  initState() {
    super.initState();
    if (users.isEmpty) {
      print(users.toString());
    }
    print('Test');
  }

  @override
  Widget build(BuildContext context) {
    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      Text("Profile"),
      buildSwipe(),
      Text("Matches")
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              AuthService().signOut();
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Center(
        child: _widgetSet.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Zesti"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Matches"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: CustomTheme.lightTheme.primaryColor,
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

  // Stack of user swipe cards
  Widget buildSwipe() {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            users.isEmpty
                ? Text('No more users')
                : Stack(children: users.map(buildCard).toList()),
            Expanded(child: Container()),
          ],
        ),
      ),
    );
  }

  // User card swipe widget
  Widget buildCard(User user) {
    final userIndex = users.indexOf(user);
    final isUserInFocus = userIndex == users.length - 1;

    // Mouse point listener (drag/move events).
    return Listener(
      onPointerMove: (pointerEvent) {
        final provider =
            Provider.of<CardPositionProvider>(context, listen: false);
        provider.updatePosition(pointerEvent.localDelta.dx);
      },
      onPointerCancel: (_) {
        final provider =
            Provider.of<CardPositionProvider>(context, listen: false);
        provider.resetPosition();
      },
      onPointerUp: (_) {
        final provider =
            Provider.of<CardPositionProvider>(context, listen: false);
        provider.resetPosition();
      },
      // The Draggable user card.
      child: Draggable(
        child: UserCard(user: user, isUserInFocus: isUserInFocus),
        feedback: Material(
          type: MaterialType.transparency,
          child: UserCard(user: user, isUserInFocus: isUserInFocus),
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) => onDragEnd(details, user),
      ),
    );
  }

  Future<User> repopulate() async {
    final response = await http.get(Uri.parse(''));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    User test = User(
        name: decoded['first-name'],
        designation: 'Test',
        mutualFriends: 69,
        bio: decoded['bio'],
        age: 24,
        imgUrl: 'assets/profile.jpg',
        location: 'Test');
    return test;
  }

  void onDragEnd(DraggableDetails details, User user) {
    final minimumDrag = 100;
    if (details.offset.dx > minimumDrag) {
      user.isSwipedOff = true;
    } else if (details.offset.dx < -minimumDrag) {
      user.isLiked = true;
    }
    setState(() => users.remove(user));
    if (users.isEmpty) {
      setState(() async {
        User test = await repopulate();
        users.add(test);
      });
    }
  }
}
