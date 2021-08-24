import 'dart:async';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/home/chat.dart';

// Widget for listening to matchlist changes
class Matches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Listen to authentication stream
    final user = Provider.of<User?>(context);

    // Check for non-user
    if (user == null) {
      return Text('Error');
    } else {
      // var for initialData (honestly just a dummy variable)
      var completer = new Completer<List<dynamic>>();
      completer.complete([]);
      // StreamProvider to listen to matchlist from DatabaseService
      return StreamProvider<Future<List<dynamic>>>.value(
        initialData: completer.future,
        value: DatabaseService(uid: user.uid).matches,
        child: Scaffold(
          body: MatchList(uid: user.uid),
        ),
      );
    }
  }
}

// Widget for loading matchlist data when changes are notified
class MatchList extends StatefulWidget {
  final String uid;
  MatchList({
    Key? key,
    required this.uid,
  }) : super(key: key);
  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  @override
  Widget build(BuildContext context) {
    // StreamProvider from Matches widget above
    final _matchList = Provider.of<Future<List<dynamic>>>(context);
    return FutureBuilder(
      future: _matchList,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        // On error
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
          // On success
        } else if (snapshot.connectionState == ConnectionState.done) {
          List<Widget> widgetList = [];
          List<dynamic>? data = snapshot.data;
          // Unpack list of ZestiUsers and load into list of
          // MatchSheet widgets
          if (data != null) {
            for (ZestiUser matchedUser in data) {
              widgetList.add(MatchSheet(
                uid: widget.uid,
                chatid: matchedUser.chatid,
                name: matchedUser.first,
                profpic: matchedUser.profpic,
              ));
            }
          }
          // Generate listview of loaded MatchSheet widgets
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('MATCHES',
                    style: TextStyle(color: Colors.orange[900])),
              ),
              Expanded(child: ListView(children: widgetList)),
            ],
          );
        }
        // Otherwise, return a loading screen
        else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

// Widget for individual match to display in listview
class MatchSheet extends StatelessWidget {
  final String uid;
  final String? chatid;
  final String name;
  final ImageProvider<Object> profpic;
  MatchSheet({
    Key? key,
    required this.uid,
    required this.chatid,
    required this.name,
    required this.profpic,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // When sheet is tapped, navigates to chat with the match
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  Chat(uid: uid, chatid: chatid, name: name, profpic: profpic)),
        );
      },
      // Display match info (user data) on the sheet
      child: Container(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CircleAvatar(
                radius: 40.0,
                backgroundImage: profpic,
                backgroundColor: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(name,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  SizedBox(height: 10.0),
                  Text('Hi there!', style: TextStyle(fontSize: 16))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
