import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:zesti/services/auth.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/views/auth/start.dart';
import 'package:zesti/widgets/usercard.dart';
import 'package:zesti/providers/cardposition.dart';
import 'package:zesti/views/home/editprofile.dart';
import 'package:zesti/views/home/matches.dart';

// Widget containing swiping, profile management, and matches
class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Firebase storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Inital widget to display
  int _selectedIndex = 1;

  // List of users to display in swipe cards
  List<ZestiUser> _userList = []; // Actual loaded data (from _future)

  // Receives user data from http request
  // Obsolete (move to databaseService and disregard API call)
  Future<List<ZestiUser>> _getUserData(String? uid) async {
    try {
      if (uid == null) {
        throw Exception();
      }
      // http request
      final response = await http
          .get(Uri.parse('http://10.250.125.170:8080/swipe-list?uid=' + uid));
      // Decode JSON to hash map
      final decoded = json.decode(response.body) as Map<String, dynamic>;
      // Obtain image from photo-ref field
      Uint8List? profpicref =
          await _storage.ref().child(decoded['photo-ref']).getData();
      ImageProvider<Object> profpic;
      if (profpicref == null) {
        profpic = AssetImage('assets/profile.jpg');
      } else {
        profpic = MemoryImage(profpicref);
      }
      // Load data into User class
      ZestiUser testUser = ZestiUser(
          uid: decoded['uid'],
          chatid: '',
          name: decoded['first-name'],
          designation: 'Test',
          mutualFriends: 69,
          bio: decoded['bio'],
          age: 24,
          profpic: profpic,
          location: 'Test');
      // Add user to _userList
      _userList.add(testUser);
    } on Error catch (e) {
      print('Error: $e');
    }
    return _userList;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return Text('User Error');
    }

    Size size = MediaQuery.of(context).size;
    // Widget list for bottom nav bar
    final List<Widget> _widgetSet = <Widget>[
      EditProfile(
        uid: user.uid,
      ),
      buildSwipe(
        user.uid,
      ),
      Matches(),
    ];

    // Main page widget (contains nav bar pages as well)
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: CustomTheme.lightTheme.primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Start()),
              );
            },
            color: Colors.white,
          ),
        ],
      ),
      body: Center(
        child: _widgetSet.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: size.width * 0.08,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Zesti"),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble), label: "Matches"),
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
  Widget buildSwipe(String uid) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        // FutureBuilder for http request payload
        child: FutureBuilder(
          future: DatabaseService(uid: uid).getSwiping(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            // On success, build swipe cards out of _userList
            else if (snapshot.connectionState == ConnectionState.done) {
              _userList = snapshot.data as List<ZestiUser>;
              print(_userList.length);
              return Stack(children: _userList.map(buildCard).toList());
            }
            // Otherwise, return a loading screen
            else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  // User card swipe widget
  Widget buildCard(ZestiUser user) {
    final userIndex = _userList.indexOf(user);
    final isUserInFocus = userIndex == _userList.length - 1;

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

  // If card is dragged past a threshold, perform operations
  void onDragEnd(DraggableDetails details, ZestiUser user) async {
    // Minimum offset for swipe
    final minimumDrag = 100;
    // Swipe logic
    if (details.offset.dx > minimumDrag) {
      _userList.removeAt(0);
      await DatabaseService(uid: user.uid).updateLiked(user.uid);
    } else if (details.offset.dx < -minimumDrag) {
      _userList.removeAt(0);
      await DatabaseService(uid: user.uid).updateDisliked(user.uid);
    }
    print(_userList.length);
    // Call to repopulate if _userList is empty
    if (_userList.isEmpty) {
      setState(() {});
    }
  }
}
