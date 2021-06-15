import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/theme/theme.dart';
import 'package:provider/provider.dart';
// import 'package:zesti/models/user.dart';

class Matches extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    if (user == null) {
      return Text('Error');
    } else {
      return StreamProvider<List<ZestiUser>>.value(
        initialData: [],
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
    final matchList = Provider.of<List<ZestiUser>>(context);
    for (var user in matchList) {
      print(user);
    }
    return Container();
  }
}
