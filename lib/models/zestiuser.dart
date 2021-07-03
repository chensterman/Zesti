import 'package:flutter/material.dart';

// User class for the app
// Useful to hold unpackaged requests from the database
class ZestiUser {
  final String uid;
  final String chatid;
  final String name;
  final String designation;
  final int mutualFriends;
  final int age;
  final ImageProvider<Object> profpic;
  final String location;
  final String bio;

  ZestiUser({
    required this.uid,
    required this.chatid,
    required this.designation,
    required this.mutualFriends,
    required this.name,
    required this.age,
    required this.profpic,
    required this.location,
    required this.bio,
  });
}
