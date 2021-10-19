import 'package:flutter/material.dart';

// User class for the app.
//  Useful to hold unpackaged requests from the database.
class ZestiUser {
  final String uid; // Firestore doc ID of the user.
  final String first; // First name of the user.
  final String last; // Last name of the user.
  final String bio; // Bio of the user.
  final String dIdentity; // Dating identity of the user.
  final String dInterest; // Dating interest of the user.
  final String house; // Harvard house of the user.
  final String photoURL; // Firebase Storage URL of user's profile picture.
  final ImageProvider<Object> profPic; // Profile picture of the user.
  final int age; // Age of the user.
  final String year; // Grad year of the user.
  final String zestKey; // Zestkey of the user.

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
    required this.year,
    required this.zestKey,
  });
}
