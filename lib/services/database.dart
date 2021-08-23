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

  // Firebase Storage instance.
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

  Future<ZestiUser> _userFirebaseToZesti(DocumentReference data) async {
    // Get snapshot from reference
    DocumentSnapshot snapshot = await data.get();
    // Convert snapshot to data in hash map form
    Map<String, dynamic> mapdata = snapshot.data() as Map<String, dynamic>;
    // Initialize profile picture variable
    ImageProvider<Object> profpic;

    // Check if user has an uploaded profile picture.
    // Set profile picture variable to the corresponding case.
    if (mapdata['photo-ref'] == null) {
      profpic = AssetImage('assets/profile.jpg');
    } else {
      Uint8List? profpicref =
          await _storage.ref().child(mapdata['photo-ref']).getData();
      if (profpicref == null) {
        profpic = AssetImage('assets/profile.jpg');
      } else {
        profpic = MemoryImage(profpicref);
      }
    }

    // Return the ZestiUser object.
    return ZestiUser(
        uid: data.id,
        designation: 'Test',
        mutualFriends: 69,
        name: mapdata['first-name'],
        age: 69,
        profpic: profpic,
        location: 'Test',
        bio: mapdata['bio']);
  }

  Stream<QuerySnapshot> messages(String chatid) {
    return chatCollection
        .doc(chatid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Stream<Future<Map<String, dynamic>>> profileInfo() {
    return userCollection.doc(uid).snapshots().map(_userDocFromSnapshot);
  }

  Future<Map<String, dynamic>> _userDocFromSnapshot(
      DocumentSnapshot snapshot) async {
    Map<String, dynamic> mapdata = snapshot.data() as Map<String, dynamic>;
    // Initialize profile picture variable
    ImageProvider<Object> profpic;
    // Check if user has an uploaded profile picture.
    // Set profile picture variable to the corresponding case.
    if (mapdata['photo-ref'] == null) {
      profpic = AssetImage('assets/profile.jpg');
    } else {
      Uint8List? profpicref =
          await _storage.ref().child(mapdata['photo-ref']).getData();
      if (profpicref == null) {
        profpic = AssetImage('assets/profile.jpg');
      } else {
        profpic = MemoryImage(profpicref);
      }
    }
    mapdata['photo-ref'] = profpic;
    return mapdata;
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
    for (DocumentReference data in dataList) {
      ZestiUser match = await _userFirebaseToZesti(data);
      matchedList.add(match);
    }
    return matchedList;
  }

  // Get user info from document fields.
  Future<Map<String, dynamic>> getInfo() async {
    DocumentSnapshot doc = await userCollection.doc(uid).get();
    return doc.data() as Map<String, dynamic>;
  }

  Future<List<ZestiUser>> getSwiping() async {
    Map<String, dynamic> data = await getInfo();
    List<String> queryIdentity = [];
    List<String> queryInterest = [];
    switch (data['dating-identity']) {
      case 'non-binary':
        {
          switch (data['dating-interest']) {
            case 'everyone':
              {
                queryIdentity = ['man', 'woman', 'non-binary'];
                queryInterest = ['everyone'];
              }
              break;

            case 'man':
              {
                queryIdentity = ['man'];
                queryInterest = ['everyone'];
              }
              break;

            case 'woman':
              {
                queryIdentity = ['woman'];
                queryInterest = ['everyone'];
              }
              break;
          }
        }
        break;

      case 'man':
        {
          switch (data['dating-interest']) {
            case 'everyone':
              {
                queryIdentity = ['man', 'woman', 'non-binary'];
                queryInterest = ['man', 'everyone'];
              }
              break;

            case 'man':
              {
                queryIdentity = ['man'];
                queryInterest = ['man', 'everyone'];
              }
              break;

            case 'woman':
              {
                queryIdentity = ['woman'];
                queryInterest = ['man', 'everyone'];
              }
              break;
          }
        }
        break;

      case 'woman':
        {
          switch (data['dating-interest']) {
            case 'everyone':
              {
                queryIdentity = ['man', 'woman', 'non-binary'];
                queryInterest = ['woman', 'everyone'];
              }
              break;

            case 'man':
              {
                queryIdentity = ['man'];
                queryInterest = ['woman', 'everyone'];
              }
              break;

            case 'woman':
              {
                queryIdentity = ['woman'];
                queryInterest = ['woman', 'everyone'];
              }
              break;
            default:
              {
                queryIdentity = ['man'];
                queryInterest = ['woman'];
              }
              break;
          }
        }
        break;
    }
    print(queryIdentity);
    print(queryInterest);
    List<ZestiUser> userList = [];
    while (userList.length < 3) {
      QuerySnapshot snapshot;
      if (queryIdentity.length == 3) {
        snapshot = await userCollection
            .where('dating-interest', whereIn: queryInterest)
            .limit(1)
            .get();
      } else {
        snapshot = await userCollection
            .where('dating-identity', isEqualTo: queryIdentity[0])
            .where('dating-interest', whereIn: queryInterest)
            .limit(1)
            .get();
      }
      if (snapshot.size == 0) {
        break;
      } else {
        String uidPotential = snapshot.docs[0].id;
        DocumentReference potentialDoc = userCollection.doc(uidPotential);
        ZestiUser potentialUser = await _userFirebaseToZesti(potentialDoc);
        userCollection
            .doc(uid)
            .collection('liked')
            .doc(uidPotential)
            .get()
            .then((docSnapshot) => {
                  if (!docSnapshot.exists) {userList.add(potentialUser)}
                });
      }
    }
    return userList;
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

    // http request Update this part in the API (no more api calls)
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
