import 'package:zesti/views/auth/start.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:zesti/views/home/swipe.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dynamic user = Provider.of<User?>(context);
    // return either Home page or Authentication
    return (user != null) ? Swipe() : Start();
  }
}
