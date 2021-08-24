import 'package:flutter/material.dart';

// User class for the app
// Useful to hold unpackaged requests from the database
class ZestiUser {
  final String uid;
  String? chatid;
  final String first;
  final String last;
  final String bio;
  final String dIdentity;
  final String dInterest;
  final String house;
  final int age;
  final ImageProvider<Object> profpic;

  ZestiUser({
    required this.uid,
    this.chatid,
    required this.first,
    required this.last,
    required this.bio,
    required this.dIdentity,
    required this.dInterest,
    required this.house,
    required this.age,
    required this.profpic,
  });
}
