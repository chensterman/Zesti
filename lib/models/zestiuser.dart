import 'package:flutter/material.dart';

// Dummy user class for the user cards
class ZestiUser {
  final String name;
  final String designation;
  final int mutualFriends;
  final int age;
  final ImageProvider<Object> profpic;
  final String location;
  final String bio;
  bool isLiked;
  bool isSwipedOff;

  ZestiUser({
    required this.designation,
    required this.mutualFriends,
    required this.name,
    required this.age,
    required this.profpic,
    required this.location,
    required this.bio,
    this.isLiked = false,
    this.isSwipedOff = false,
  });
}
