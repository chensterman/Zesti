import 'dart:async';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zesti/models/zestiuser.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/home/matchsheet.dart';

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
          body: MatchList(),
        ),
      );
    }
  }
}

// Widget for loading matchlist data when changes are notified
class MatchList extends StatefulWidget {
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
          return Text("Error");
          // On success
        } else if (snapshot.connectionState == ConnectionState.done) {
          List<Widget> widgetList = [];
          List<dynamic>? data = snapshot.data;
          // Unpack list of ZestiUsers and load into list of
          // MatchSheet widgets
          if (data != null) {
            for (ZestiUser matchedUser in data) {
              widgetList.add(MatchSheet(
                name: matchedUser.name,
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
