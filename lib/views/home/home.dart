import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:zesti/providers/cardposition.dart';

class Home extends StatefulWidget {
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Iniital widget to display
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    // User provider
    final user = Provider.of<User?>(context);

    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      Text("Profile"),
      buildSwipe(user),
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

  // User card swipe widget
  Widget buildSwipe(final user) {
    // final userIndex = users.indexOf(user);
    // final isUserInFocus = userIndex == users.length - 1;
    // Card position provider value.
    final provider = Provider.of<CardPositionProvider>(context, listen: false);

    // Mouse point listener (drag/move events).
    return Listener(
      onPointerMove: (pointerEvent) {
        provider.updatePosition(pointerEvent.localDelta.dx);
      },
      onPointerCancel: (_) {
        provider.resetPosition();
      },
      onPointerUp: (_) {
        provider.resetPosition();
      },
      // The Draggable user card.
      child: Draggable(
        child: UserCard(user: user, isUserInFocus: true),
        feedback: Material(
          type: MaterialType.transparency,
          child: UserCard(user: user, isUserInFocus: true),
        ),
        childWhenDragging: Container(),
        onDragEnd: (details) => onDragEnd(details, user),
      ),
    );
  }

  void onDragEnd(DraggableDetails details, final user) {
    final minimumDrag = 100;
    if (details.offset.dx > minimumDrag) {
    } else if (details.offset.dx < -minimumDrag) {}

    setState(() {});
  }
}
