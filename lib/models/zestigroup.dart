// Group class for the app
//  Useful to hold unpackaged requests from the database
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ZestiGroup {
  final String gid;
  final String groupName;
  final String funFact;
  final Map<DocumentReference, String> nameMap;
  final Map<DocumentReference, ImageProvider<Object>> photoMap;

  ZestiGroup(
      {required this.gid,
      required this.groupName,
      required this.funFact,
      required this.nameMap,
      required this.photoMap});
}
