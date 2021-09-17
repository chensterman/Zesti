import 'package:flutter/material.dart';

// User class for the app
//  Useful to hold unpackaged requests from the database
class ZestiUser {
  final String uid;
  final String first;
  final String last;
  final String bio;
  final String dIdentity;
  final String dInterest;
  final String house;
  final String photoURL;
  final ImageProvider<Object> profPic;
  final int age;

  ZestiUser({
    required this.uid,
    required this.first,
    required this.last,
    required this.bio,
    required this.dIdentity,
    required this.dInterest,
    required this.house,
    required this.photoURL,
    required this.profPic,
    required this.age,
  });
}
