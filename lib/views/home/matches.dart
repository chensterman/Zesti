import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:zesti/views/home/matchsheet.dart';

// import 'package:zesti/models/user.dart';

class Matches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return Text('Error');
    } else {
      var completer = new Completer<List<dynamic>>();
      completer.complete([]);
      return StreamProvider<Future<List<dynamic>>>.value(
        initialData: completer.future,
        value: DatabaseService(uid: user.uid).matches,
        child: Scaffold(
          body: MatchList(),
        ),
      );
    }
  }
}

class MatchList extends StatefulWidget {
  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  @override
  Widget build(BuildContext context) {
    final _matchList = Provider.of<Future<List<dynamic>>>(context);
    return FutureBuilder(
      future: _matchList,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasError) {
          return Text("Error");
        } else if (snapshot.connectionState == ConnectionState.done) {
          List<Widget> widgetList = [];
          List<dynamic>? data = snapshot.data;
          if (data != null) {
            for (ZestiUser matchedUser in data) {
              widgetList.add(MatchSheet(
                name: matchedUser.name,
                profpic: matchedUser.profpic,
              ));
            }
          }
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
