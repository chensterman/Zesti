// Group class for the app.
//  Useful to hold unpackaged requests from the database.
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ZestiGroup {
  final String gid; // Firestore doc ID of the group.
  final String groupName; // Name of the group.
  final String groupTagline; // Tagline of the group.
  final Map<DocumentReference, String>
      nameMap; // Maps document reference of all users in group to their first name.
  final Map<DocumentReference, ImageProvider<Object>>
      photoMap; // Maps document reference of all users in group to their profile picture.

  ZestiGroup(
      {required this.gid,
      required this.groupName,
      required this.groupTagline,
      required this.nameMap,
      required this.photoMap});
}
