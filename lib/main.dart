import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/services/auth.dart';
import 'package:zesti/wrappers/authwrapper.dart';

// Main function to run:
//  Firebase must be initialized.
//  App us ran.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(App());
}

// App class:
//  Stream to track authentication.
class App extends StatelessWidget {
  // This widget is the root of your application:
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
        initialData: null,
        value: AuthService().user,
        child: MaterialApp(
          home: AuthWrapper(),
        ));
  }
}
