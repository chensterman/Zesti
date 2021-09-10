import 'dart:typed_data';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // Access to 'groups' collection.
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

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
          'age': null,
          'house': null,
          'dating-identity': null,
          'dating-interest': null,
          'photo-ref': null,
          'bio': null,
          'group-count': 0,
          'zest-key': uuid.v4().substring(0, 8),
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed"));
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
  Future<void> updateAge(DateTime birthday) async {
    Duration difference = DateTime.now().difference(birthday);
    num age = difference.inDays ~/ 365;
    await userCollection
        .doc(uid)
        .update({'age': age})
        .then((value) => print("Age Updated"))
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
  Future<void> updateBio(String? bio) async {
    await userCollection
        .doc(uid)
        .update({'bio': bio})
        .then((value) => print("Bio Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Retrieves the stored image from a given reference to Firebase Storage.
  Future<ImageProvider<Object>> getProfPic(String? photoref) async {
    ImageProvider<Object> profpic;

    // Check if user has an uploaded profile picture.
    // Set profile picture variable to the corresponding case.
    if (photoref == null) {
      profpic = AssetImage('assets/profile.jpg');
    } else {
      Uint8List? profpicref = await _storage.ref().child(photoref).getData();
      if (profpicref == null) {
        profpic = AssetImage('assets/profile.jpg');
      } else {
        profpic = MemoryImage(profpicref);
      }
    }
    return profpic;
  }

  // Stream to retrieve profile info from the given uid.
  Stream<DocumentSnapshot> getProfileInfo() {
    return userCollection.doc(uid).snapshots();
  }

  // Stream to retrieve list of matches from the given uid.
  Stream<QuerySnapshot> getMatches() {
    return userCollection.doc(uid).collection("matched").snapshots();
  }

  // Stream to retrieve match recommendations (generated with function below).
  Stream<QuerySnapshot> getRecommendations() {
    return userCollection
        .doc(uid)
        .collection('recommendations')
        .orderBy('timestamp')
        .snapshots();
  }

  // Stream to retrieve incoming match requests.
  Stream<QuerySnapshot> getIncoming() {
    return userCollection
        .doc(uid)
        .collection('incoming')
        .orderBy('timestamp')
        .snapshots();
  }

  // Stream to retrieve messages from a given chatid.
  Stream<QuerySnapshot> getMessages(String? chatid) {
    return chatCollection
        .doc(chatid)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Stream to retrieve messages from a given chatid.
  Stream<QuerySnapshot> getGroups() {
    return userCollection
        .doc(uid)
        .collection('groups')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Send a chat message.
  Future<void> sendMessage(String? chatid, String type, String content) async {
    await chatCollection
        .doc(chatid)
        .collection('messages')
        .doc(uuid.v1())
        .set({
          'timestamp': DateTime.now(),
          'sender': uid,
          'type': type,
          'content': content,
        })
        .then((value) => print("Message Sent"))
        .catchError((error) => print("Failed to send message: $error"));
  }

  // Helper function for converting a user DocumentReference to a dart map.
  Future<Map<String, dynamic>> _referenceToMap(
      DocumentReference userRef) async {
    // Get snapshot of user doc reference.
    DocumentSnapshot snapshot = await userRef.get();

    // Convert snapshot data into a dart map.
    Map<String, dynamic> mapData = snapshot.data() as Map<String, dynamic>;

    // Add user reference to the dart map.
    mapData['user-ref'] = userRef;
    return mapData;
  }

  // Generates random match recommendations based on dating identity and interest.
  Future<void> generateRecommendations() async {
    // Get current user info
    Map<String, dynamic> currUser =
        await _referenceToMap(userCollection.doc(uid));

    // Get querying parameters based on user info
    List<String> queryIdentity = [];
    List<String> queryInterest = [];
    switch (currUser["dating-identity"]) {
      case 'non-binary':
        {
          switch (currUser["dating-interest"]) {
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
          switch (currUser["dating-interest"]) {
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
          switch (currUser["dating-interest"]) {
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

    // Get snapshot of all users the user reacted (liked or disliked) to. Convert
    // to list and subtract from list of all users
    QuerySnapshot reactionsSnapshot =
        await userCollection.doc(uid).collection("outgoing").get();
    final allReactions =
        reactionsSnapshot.docs.map((doc) => doc.get("user-ref").id).toList();

    QuerySnapshot usersSnapshot = await userCollection.get();
    final allUsers = usersSnapshot.docs.map((doc) => doc.id).toList();

    var availableUsers = allUsers.toSet().difference(allReactions.toSet());
    availableUsers = availableUsers.difference([uid].toSet());

    // Query based on the given parameters
    QuerySnapshot snapshot;
    if (queryIdentity.length == 3) {
      snapshot = await userCollection
          .where('dating-interest', whereIn: queryInterest)
          .get();
    } else {
      snapshot = await userCollection
          .where('dating-identity', isEqualTo: queryIdentity[0])
          .where('dating-interest', whereIn: queryInterest)
          .get();
    }

    // Create a list of potential recommendations
    List<String> snapshotUIDs = snapshot.docs.map((doc) => doc.id).toList();
    List<String> potentialUIDs =
        availableUsers.intersection(snapshotUIDs.toSet()).toList();

    // Randomly pick from potentialUIDs. Max 3 picks, unless there are less than
    // 3 potenialUIDs
    int userListMaxLength;
    if (potentialUIDs.length < 3) {
      userListMaxLength = potentialUIDs.length;
    } else {
      userListMaxLength = 3;
    }
    List<Map<String, dynamic>> userList = [];
    while (userList.length < userListMaxLength) {
      final random = new Random();
      var selectedUID = potentialUIDs[random.nextInt(potentialUIDs.length)];
      potentialUIDs.remove(selectedUID);
      DocumentReference selectedDoc = userCollection.doc(selectedUID);
      Map<String, dynamic> selectedUser = await _referenceToMap(selectedDoc);
      userList.add(selectedUser);
    }

    // Delete all currently stored recommendations.
    QuerySnapshot recommendations =
        await userCollection.doc(uid).collection("recommendations").get();
    for (QueryDocumentSnapshot recUser in recommendations.docs) {
      await recUser.reference.delete();
    }

    // Populate recommendations collection with newly generated users.
    DateTime ts = DateTime.now();
    for (Map<String, dynamic> recUser in userList) {
      await userCollection
          .doc(uid)
          .collection("recommendations")
          .doc(uuid.v4())
          .set({
        "timestamp": ts,
        "user-ref": recUser['user-ref'],
        "first-name": recUser['first-name'],
        "bio": recUser['bio'],
        "age": recUser['age'],
        "photo-ref": recUser['photo-ref'],
        "house": recUser['house'],
      });
    }
  }

  // Handles the interactions a user conducts on a recommended match.
  Future<void> outgoingInteraction(String youid, bool requested) async {
    // Define timestamp and unique ID for the interaction
    DateTime ts = DateTime.now();
    String id = uuid.v4();

    // Get current user info
    Map<String, dynamic> currUser =
        await _referenceToMap(userCollection.doc(uid));

    // Update requester's "outgoing" collection
    await userCollection
        .doc(uid)
        .collection("outgoing")
        .doc(id)
        .set({
          "timestamp": ts,
          "user-ref": userCollection.doc(youid),
          "requested": requested,
        })
        .then((value) => print(requested ? "Request sent." : "Denial sent."))
        .catchError((error) => print("Failed to send: $error"));

    // Update requestee's "incoming" collection if request is sent
    if (requested) {
      await userCollection
          .doc(youid)
          .collection("incoming")
          .doc(id)
          .set({
            "timestamp": ts,
            "user-ref": userCollection.doc(uid),
            "first-name": currUser['first-name'],
            "bio": currUser['bio'],
            "age": currUser['age'],
            "photo-ref": currUser['photo-ref'],
            "house": currUser['house'],
          })
          .then((value) => print("Incoming request received."))
          .catchError(
              (error) => print("Failed to receive incoming request: $error"));
    }
  }

  // Handles the interactions a user conducts on an incoming match request.
  Future<void> incomingInteraction(
      String youid, String? id, bool accepted) async {
    // Define timestamp and unique ID for the match (used for chat as well)
    DateTime ts = DateTime.now();
    String chatid = uuid.v4();

    // Get both user info.
    Map<String, dynamic> initiator =
        await _referenceToMap(userCollection.doc(uid));
    Map<String, dynamic> receiver =
        await _referenceToMap(userCollection.doc(youid));

    // Update user's "matched" collection on acceptance.
    if (accepted) {
      await userCollection
          .doc(uid)
          .collection("matched")
          .doc(chatid)
          .set({
            "timestamp": ts,
            "user-ref": userCollection.doc(youid),
            "first-name": receiver['first-name'],
            "photo-ref": receiver['photo-ref'],
          })
          .then((value) => print("Acceptance (initiator) sent."))
          .catchError((error) => print("Failed to send: $error"));
      await userCollection
          .doc(youid)
          .collection("matched")
          .doc(chatid)
          .set({
            "timestamp": ts,
            "user-ref": userCollection.doc(uid),
            "first-name": initiator['first-name'],
            "photo-ref": initiator['photo-ref'],
          })
          .then((value) => print("Acceptance (receiver) sent."))
          .catchError((error) => print("Failed to send: $error"));
      await chatCollection
          .doc(chatid)
          .set({
            "user1-ref": userCollection.doc(uid),
            "user2-ref": userCollection.doc(youid)
          })
          .then((value) => print("Chat created."))
          .catchError((error) => print("Failed to create chat: $error"));
    }

    // Delete the incoming request regardless of acceptance.
    await userCollection
        .doc(uid)
        .collection("incoming")
        .doc(id)
        .delete()
        .then((value) => print("Incoming request deleted."))
        .catchError(
            (error) => print("Failed to delete incoming request: $error"));
  }

  Future<void> createGroup(String gid, String groupName, String funFact) async {
    await userCollection
        .doc(uid)
        .collection("groups")
        .doc(gid)
        .set({'group-name': groupName, 'fun-fact': funFact, 'user-count': 1});
  }
}
