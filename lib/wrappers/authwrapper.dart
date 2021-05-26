import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/database.dart';
import 'package:zesti/views/auth/start.dart';
import 'package:zesti/views/home/home.dart';
import 'package:zesti/views/register/name.dart';

// AuthWrapper class:
//  Listens to authentication stream.
//  Not logged in - Start class.
//  Logged in - Swipe class.
//  Registration counts as login.
class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    print("Auth status: $user");
    if (user == null) {
      return Start();
    } else {
      // FutureBuilder required due to async DB function .get()
      return FutureBuilder(
        future:
            DatabaseService(uid: user.uid).userCollection.doc(user.uid).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          // Snapshot error handling.
          if (snapshot.hasError) {
            return Text("Error");
          }
          // On success, check for account setup boolen. Conditionally return
          // homepage or beginning of registration.
          else if (snapshot.connectionState == ConnectionState.done) {
            dynamic test = snapshot.data?.data();
            if (test['account-setup']) {
              return Home();
            } else {
              return Name();
            }
          }
          // Otherwise, return a loading screen
          else {
            return Text("loading");
          }
        },
      );
    }
  }
}
