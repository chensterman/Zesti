import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/models/zestiuser.dart';

// DatabaseService class:
//  Contains all methods and data pertaining to the user database.
class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Access to 'users' collection.
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // Access to 'chats' collection.
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  // Random id generator.
  final uuid = Uuid();

  // Creater user:
  //  Add user document to 'users' and initialize fields.
  Future<void> createUser() async {
    await userCollection
        .doc(uid)
        .set({
          'uid': uid,
          'account-setup': false,
          'first-name': null,
          'last-name': null,
          'birthday': null,
          'house': null,
          'dating-identity': null,
          'dating-interest': null,
          'photo-ref': null,
          'bio': null,
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed"));
  }

  Stream<QuerySnapshot> messages(String chatid) {
    return chatCollection
        .doc(chatid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Stream to show list of matched users
  Stream<Future<List<ZestiUser>>> get matches {
    return userCollection
        .doc(uid)
        .collection('matched')
        .snapshots()
        .map(_zestiUserFromSnapshot);
  }

  // Helper function for matched users stream - convert QuerySnapshot to
  // list of ZestiUser models.
  Future<List<ZestiUser>> _zestiUserFromSnapshot(QuerySnapshot snapshot) async {
    List<dynamic> dataList = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();
    List<ZestiUser> matchedList = [];
    for (Map<String, dynamic> data in dataList) {
      DocumentSnapshot doc = await data['user-ref'].get();
      Uint8List? profpicref =
          await _storage.ref().child(doc['photo-ref']).getData();
      ImageProvider<Object> profpic;
      if (profpicref == null) {
        profpic = AssetImage('assets/profile.jpg');
      } else {
        profpic = MemoryImage(profpicref);
      }
      matchedList.add(ZestiUser(
          uid: doc['uid'],
          chatid: data['chatid'],
          designation: 'Test',
          mutualFriends: 69,
          name: doc['first-name'],
          age: 69,
          profpic: profpic,
          location: 'Test',
          bio: data['bio']));
    }
    return matchedList;
  }

  /*
    // http request
    String urlBase = 'http://10.250.125.170:8080/matches?';
    String arg1 = 'uid=' + uid;
    final response = await http.get(Uri.parse(urlBase + arg1));
    Map decoded = json.decode(response.body) as Map<String, List<Map<String, dynamic>>>;
    List<Map<String, dynamic>> data = decoded['matches'];
    List<ZestiUser> matchedList = [];
    for (Map<String, dynamic> user in data){
      Uint8List? profpicref =
          await _storage.ref().child(user['photo-ref']).getData();
      ImageProvider<Object> profpic;
      if (profpicref == null) {
        profpic = AssetImage('assets/profile.jpg');
      } else {
        profpic = MemoryImage(profpicref);
      }
      matchedList.add(ZestiUser(
          uid: user['uid'],
          designation: 'Test',
          mutualFriends: 69,
          name: user['first-name'],
          age: 69,
          profpic: profpic,
          location: 'Test',
          bio: user['bio']));
    }
    */

  // Get user info from document fields.
  Future<Map<String, dynamic>> getInfo() async {
    // http request
    String urlBase = 'http://10.250.125.170:8080/user-info?';
    String arg1 = 'uid=' + uid;
    final response = await http.get(Uri.parse(urlBase + arg1));
    return json.decode(response.body) as Map<String, dynamic>;
  }

  // Update the account setup:
  //  Determines whether or not user should be should be shown the beginning
  //  of registration or the home page. Basically should set to true after user
  //  completes steps in "register" folder.
  Future<void> updateAccountSetup() async {
    await userCollection.doc(uid).update({'account-setup': true});
  }

  // Update user first and last name.
  Future<void> updateName(String first, String last) async {
    await userCollection
        .doc(uid)
        .update({'first-name': first, 'last-name': last})
        .then((value) => print("Name Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user birthday.
  Future<void> updateBirthday(Timestamp birthday) async {
    await userCollection
        .doc(uid)
        .update({'birthday': birthday})
        .then((value) => print("Birthday Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user house.
  Future<void> updateHouse(String house) async {
    await userCollection
        .doc(uid)
        .update({'house': house})
        .then((value) => print("House Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user identity.
  Future<void> updateDatingIdentity(String identity) async {
    await userCollection
        .doc(uid)
        .update({'dating-identity': identity})
        .then((value) => print("Identity Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user interest.
  Future<void> updateDatingInterest(String interest) async {
    await userCollection
        .doc(uid)
        .update({'dating-interest': interest})
        .then((value) => print("Interest Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user photo.
  Future<void> updatePhoto(String storageRef) async {
    await userCollection
        .doc(uid)
        .update({'photo-ref': storageRef})
        .then((value) => print("Photo Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user bio.
  Future<void> updateBio(String bio) async {
    await userCollection
        .doc(uid)
        .update({'bio': bio})
        .then((value) => print("Bio Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future<void> updateLiked(String youid) async {
    await userCollection
        .doc(uid)
        .collection('liked')
        .doc(uuid.v4())
        .set({'timestamp': DateTime.now(), 'user': youid})
        .then((value) => print("Liked"))
        .catchError((error) => print("Failed to like: $error"));

    // http request
    String urlBase = 'http://10.250.125.170:8080/match-check?';
    String arg1 = 'meid=' + uid;
    String arg2 = 'youid=' + youid;
    final response = await http.get(Uri.parse(urlBase + arg1 + '&' + arg2));
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    if (decoded['result']) {
      String gen = uuid.v4();
      DateTime ts = DateTime.now();
      await userCollection
          .doc(uid)
          .collection('matched')
          .doc(gen)
          .set({'timestamp': ts, 'user': youid})
          .then((value) => print("New Match"))
          .catchError((error) => print("Failed to match: $error"));
      await userCollection
          .doc(youid)
          .collection('matched')
          .doc(gen)
          .set({'timestamp': ts, 'user': uid})
          .then((value) => print("New Match"))
          .catchError((error) => print("Failed to match: $error"));
      await chatCollection.doc(gen).set({'user1': uid, 'user2': youid});
    }
  }

  Future<void> sendMessage(String chatid, String type, String content) async {
    await chatCollection
        .doc(chatid)
        .collection('messages')
        .doc(uuid.v4())
        .set({
          'timestamp': DateTime.now(),
          'sender': uid,
          'type': type,
          'content': content,
        })
        .then((value) => print("Message Sent"))
        .catchError((error) => print("Failed to send message: $error"));
  }
}
