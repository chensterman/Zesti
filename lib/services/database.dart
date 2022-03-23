import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/models/zestigroup.dart';
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

  // Access to 'groups' collection.
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection('groups');

  // Access to 'chats' collection.
  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  // Access to 'partners' collection.
  final CollectionReference partnerCollection =
      FirebaseFirestore.instance.collection('partners');

  // Access to 'reports' collection.
  final CollectionReference reportCollection =
      FirebaseFirestore.instance.collection('reports');

  // Random id generator.
  final uuid = Uuid();

  // Delete user.
  Future<void> deleteUser() async {
    // Loop through all matches and unmatch with the other user.
    QuerySnapshot allMatched =
        await userCollection.doc(uid).collection("matched").get();
    for (QueryDocumentSnapshot doc in allMatched.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      await unmatch(data['user-ref'].id, doc.id);
    }
    // Loop through all groups and leave each one.
    QuerySnapshot allGroups =
        await userCollection.doc(uid).collection("groups").get();
    for (QueryDocumentSnapshot doc in allGroups.docs) {
      await leaveGroup(doc.id);
    }
    // Delete the user document.
    await userCollection.doc(uid).delete();
  }

  // Create user:
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
          'dating-intent': null,
          'photo-ref': null,
          'bio': null,
          'year': null,
          'zest-key': null,
        })
        .then((value) => print("User added"))
        .catchError((error) => print("Failed"));
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////// DATABASE OPERATIONS PERTAINING TO THE CURRENT LOGGED IN USER
  //////////////////////////////////////////////////////////////////////////////////////////

  /////////////// CURRENT USER - "update" REQUESTS

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
  Future<void> updateAge(num age) async {
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

  // Update user year.
  Future<void> updateYear(String year) async {
    await userCollection
        .doc(uid)
        .update({'year': year})
        .then((value) => print("Year Updated"))
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

  // Update user intent.
  Future<void> updateDatingIntent(String intent) async {
    await userCollection
        .doc(uid)
        .update({'dating-intent': intent})
        .then((value) => print("Intent Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user photo.
  Future<void> updatePhoto(File? image) async {
    if (image == null) {
      await userCollection
          .doc(uid)
          .update({'photo-ref': null})
          .then((value) => print("Photo Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    } else {
      String storageRefPut = "profpics/" + uid + "/" + uuid.v4() + ".jpg";
      await _storage.ref(storageRefPut).putFile(image);
      await userCollection
          .doc(uid)
          .update({'photo-ref': storageRefPut})
          .then((value) => print("Photo Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    }
  }

  // Update user bio.
  Future<void> updateBio(String bio) async {
    await userCollection
        .doc(uid)
        .update({'bio': bio})
        .then((value) => print("Bio Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  // Update user ZestKey.
  Future<void> updateZestKey(String zestKey) async {
    await userCollection
        .doc(uid)
        .update({'zest-key': zestKey})
        .then((value) => print("ZestKey Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  /////////////// CURRENT USER - "list" REQUESTS

  // Check for existing ZestKey.
  Future<bool> checkZestKey(String zestKey) async {
    QuerySnapshot sameKey =
        await userCollection.where('zest-key', isEqualTo: zestKey).get();
    return sameKey.docs.length == 0 ? false : true;
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

  // Stream to retrieve list of matches from the given uid.
  Stream<QuerySnapshot> getMatches() {
    return userCollection.doc(uid).collection("matched").snapshots();
  }

  // Stream to retrieve all group references of a user.
  Stream<QuerySnapshot> getGroups() {
    return userCollection
        .doc(uid)
        .collection('groups')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  //////////////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////// DATABASE OPERATIONS PERTAINING TO GROUPS
  //////////////////////////////////////////////////////////////////////////////////////////

  /////////////// GROUP - "update" REQUESTS

  // Update group name.
  Future<void> updateGroupName(String gid, String groupName) async {
    await groupCollection
        .doc(gid)
        .update({'group-name': groupName})
        .then((value) => print("Group Name Updated"))
        .catchError((error) => print("Failed to update group name: $error"));
  }

  // Update group tagline.
  Future<void> updateGroupTagline(String gid, String groupTagline) async {
    await groupCollection
        .doc(gid)
        .update({'fun-fact': groupTagline})
        .then((value) => print("Group Tagline Updated"))
        .catchError((error) => print("Failed to update group tagline: $error"));
  }

  // Stream to retrieve group recommendations (generated with function below).
  Stream<QuerySnapshot> getGroupRecommendations(String gid) {
    return groupCollection
        .doc(gid)
        .collection('recommendations')
        .orderBy('timestamp')
        .snapshots();
  }

  // Stream to retrieve incoming group requests.
  Stream<QuerySnapshot> getGroupIncoming(String gid) {
    return groupCollection
        .doc(gid)
        .collection('incoming')
        .orderBy('timestamp')
        .snapshots();
  }

  // Stream to retrieve list of matches from the given gid.
  Stream<QuerySnapshot> getGroupMatches(String gid) {
    return groupCollection.doc(gid).collection("matched").snapshots();
  }

  // Stream to retrieve all users.
  Stream<QuerySnapshot> getGroupUsers(String gid) {
    return groupCollection
        .doc(gid)
        .collection('users')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Retrieves all info of a group document including user photos.
  Future<ZestiGroup> getGroupInfo(DocumentReference groupRef) async {
    // Get document snapshot of the group reference.
    DocumentSnapshot groupSnapshot = await groupRef.get();

    // Convert the snapshot into a map.
    Map<String, dynamic> groupInfo =
        groupSnapshot.data() as Map<String, dynamic>;

    // Get query of all users in this group and convert to a list.
    QuerySnapshot groupUsers = await groupRef.collection("users").get();
    List groupUserRefs =
        groupUsers.docs.map((doc) => doc.get("user-ref")).toList();

    // Instantiate the ZestiGroup nameMap.
    Map<DocumentReference, String> nameMap = {};
    // Instantiate the ZestiGroup photoMap.
    Map<DocumentReference, ImageProvider<Object>> photoMap = {};

    // Add document reference, String/Image pairs into the respective maps.
    for (DocumentReference userRef in groupUserRefs) {
      DocumentSnapshot userSnapshot = await userRef.get();
      ImageProvider<Object> photo =
          await getPhoto(userSnapshot.get("photo-ref"));
      String name = await userSnapshot.get("first-name");
      nameMap[userRef] = name;
      photoMap[userRef] = photo;
    }

    // Return a ZestiGroup instance.
    return ZestiGroup(
        gid: groupRef.id,
        groupName: groupInfo['group-name'],
        groupTagline: groupInfo['fun-fact'],
        nameMap: nameMap,
        photoMap: photoMap);
  }

  // Retrieves all info of a user document including profile picture.
  Future<ZestiUser> getUserInfo(DocumentReference userRef) async {
    DocumentSnapshot userSnapshot = await userRef.get();
    Map<String, dynamic> userInfo = userSnapshot.data() as Map<String, dynamic>;
    String photoURL = "profpics/default/profile.jpg";
    if (userInfo['photo-ref'] != null) {
      photoURL = userInfo['photo-ref'];
    }
    return ZestiUser(
      uid: userRef.id,
      first: userInfo['first-name'],
      last: userInfo['last-name'],
      bio: userInfo['bio'],
      dIdentity: userInfo['dating-identity'],
      dInterest: userInfo['dating-interest'],
      dIntent: userInfo['dating-intent'],
      house: userInfo['house'],
      photoURL: photoURL,
      profPic: await getPhoto(photoURL),
      age: userInfo['age'],
      year: userInfo['year'],
      zestKey: userInfo['zest-key'],
    );
  }

  // Retrieves the stored image from a given reference to Firebase Storage.
  Future<ImageProvider<Object>> getPhoto(String? photoURL) async {
    ImageProvider<Object> photo;

    // Check if user has an uploaded profile picture.
    // Set profile picture variable to the corresponding case.
    if (photoURL == null) {
      photo = AssetImage('assets/profile.jpg');
    } else {
      Uint8List? photoData = await _storage.ref().child(photoURL).getData();
      if (photoData == null) {
        photo = AssetImage('assets/profile.jpg');
      } else {
        photo = MemoryImage(photoData);
      }
    }
    return photo;
  }

  // Stream to retrieve messages from a given chatid.
  Stream<QuerySnapshot> getMessages(DocumentReference chatRef) {
    return chatRef
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Retrieves document fields from a given chat reference.
  Future<Map<String, dynamic>> getChatInfo(DocumentReference chatRef) async {
    DocumentSnapshot snapshot = await chatRef.get();
    return snapshot.data() as Map<String, dynamic>;
  }

  // Send a chat message.
  Future<void> sendMessage(
      DocumentReference chatRef, String type, String content) async {
    await chatRef
        .collection('messages')
        .doc()
        .set({
          'timestamp': DateTime.now(),
          'sender-ref': userCollection.doc(uid),
          'type': type,
          'content': content,
        })
        .then((value) => print("Message Sent"))
        .catchError((error) => print("Failed to send message: $error"));
  }

  // Unmatch with a user.
  Future<void> unmatch(String youid, String chatid) async {
    await userCollection.doc(uid).collection("matched").doc(chatid).delete();
    await userCollection.doc(youid).collection("matched").doc(chatid).delete();
  }

  // Unmatch with a group.
  Future<void> unmatchGroup(String gid, String yougid, String chatid) async {
    await groupCollection.doc(gid).collection("matched").doc(chatid).delete();
    await groupCollection
        .doc(yougid)
        .collection("matched")
        .doc(chatid)
        .delete();
  }

  // Handles the interactions a user conducts on a recommended match.
  Future<void> outgoingInteraction(String youid, bool requested) async {
    // Define timestamp and for the interaction
    DateTime ts = DateTime.now();

    // Update requester's "outgoing" collection.
    await userCollection
        .doc(uid)
        .collection("outgoing")
        .doc(youid)
        .set({
          "timestamp": ts,
          "user-ref": userCollection.doc(youid),
          "requested": requested,
        })
        .then((value) => print(requested ? "Request sent." : "Denial sent."))
        .catchError((error) => print("Failed to send: $error"));

    // Delete from the requester's "recommendations" collection.
    await userCollection
        .doc(uid)
        .collection("recommendations")
        .doc(youid)
        .delete();

    // To avoid double matching, also delete from the requestee's "recommendations" collection (even if it is not there).
    await userCollection
        .doc(youid)
        .collection("recommendations")
        .doc(uid)
        .delete();

    // Update requestee's "incoming" collection if request is sent
    if (requested) {
      await userCollection
          .doc(youid)
          .collection("incoming")
          .doc(uid)
          .set({
            "timestamp": ts,
            "user-ref": userCollection.doc(uid),
          })
          .then((value) => print("Incoming request received."))
          .catchError(
              (error) => print("Failed to receive incoming request: $error"));
    }
  }

  // Handles the interactions a user conducts on an incoming match request.
  Future<void> incomingInteraction(String youid, bool accepted) async {
    // Initialize timestamp for the match.
    DateTime ts = DateTime.now();

    // Update user's "matched" collection on acceptance.
    if (accepted) {
      // Create chat document (generated id is used to identify the match).
      DocumentReference chatRef = chatCollection.doc();

      // Create the chat document of the given match.
      await chatCollection
          .doc(chatRef.id)
          .set({
            "timestamp": ts,
            "type": "one-on-one",
            "user1-ref": userCollection.doc(uid),
            "user2-ref": userCollection.doc(youid)
          })
          .then((value) => print("Chat created."))
          .catchError((error) => print("Failed to create chat: $error"));

      // Add to the users collection of the chat document.
      await chatCollection
          .doc(chatRef.id)
          .collection("users")
          .doc(uid)
          .set({
            "user-ref": userCollection.doc(uid),
          })
          .then((value) => print("User added."))
          .catchError((error) => print("Failed to add user: $error"));
      await chatCollection
          .doc(chatRef.id)
          .collection("users")
          .doc(youid)
          .set({
            "user-ref": userCollection.doc(youid),
          })
          .then((value) => print("User added."))
          .catchError((error) => print("Failed to add user: $error"));

      // Update "matched" collection of each user.
      await userCollection
          .doc(uid)
          .collection("matched")
          .doc(chatRef.id)
          .set({
            "timestamp": ts,
            "user-ref": userCollection.doc(youid),
            "chat-ref": chatRef,
          })
          .then((value) => print("Acceptance (initiator) sent."))
          .catchError((error) => print("Failed to send: $error"));
      await userCollection
          .doc(youid)
          .collection("matched")
          .doc(chatRef.id)
          .set({
            "timestamp": ts,
            "user-ref": userCollection.doc(uid),
            "chat-ref": chatRef,
          })
          .then((value) => print("Acceptance (receiver) sent."))
          .catchError((error) => print("Failed to send: $error"));
    }

    // Delete the incoming request regardless of acceptance.
    await userCollection
        .doc(uid)
        .collection("incoming")
        .doc(youid)
        .delete()
        .then((value) => print("Incoming request deleted."))
        .catchError(
            (error) => print("Failed to delete incoming request: $error"));
  }

  // Handles when any user creates a new group.
  Future<void> createGroup(String groupName, String funFact) async {
    // Initialize timestamp for the match.
    DateTime ts = DateTime.now();

    // Firebase auto-generate unique group ID.
    DocumentReference groupRef = groupCollection.doc();

    // Get info of user that's creating the group and convert it to a dart map.
    DocumentSnapshot currUser = await userCollection.doc(uid).get();
    Map<String, dynamic> currUserMap = currUser.data() as Map<String, dynamic>;

    // Set the group information.
    await groupRef.set({
      'group-name': groupName,
      'fun-fact': funFact,
      'timestamp': ts,
      'user-count': 1
    });
    // Set the current user info within the group.
    await groupRef.collection("users").doc(uid).set({
      'user-ref': userCollection.doc(uid),
      'timestamp': ts,
      'zest-key': currUserMap['zest-key'],
    });
    // Update the group reference in the document of the current user.
    await userCollection.doc(uid).collection("groups").doc(groupRef.id).set({
      'group-ref': groupRef,
      'timestamp': ts,
    });
  }

  // Handles when a user attemps to add a user to the group.
  Future<String> addUserToGroup(String gid, String zestKey) async {
    // Initialize timestamp for the match.
    DateTime ts = DateTime.now();

    // Get current users in the group.
    QuerySnapshot cap =
        await groupCollection.doc(gid).collection("users").get();
    // Check for a capacity of over 4.
    if (cap.docs.length >= 4) {
      return "This group is full.";
    }

    // Check for the zest-key already present in the group.
    QuerySnapshot hit = await groupCollection
        .doc(gid)
        .collection("users")
        .where('zest-key', isEqualTo: zestKey)
        .get();
    if (hit.docs.length > 0) {
      return "This user already exists in the group.";
    }

    // Search for the user by unique zest-key.
    QuerySnapshot userByZestKey =
        await userCollection.where("zest-key", isEqualTo: zestKey).get();

    // Check if Zestkey exists.
    if (userByZestKey.docs.length == 0) {
      return "This user does not exist.";
    }
    // Get the UID.
    String uidToAdd = userByZestKey.docs[0].id;
    // Add the user info to the group.
    await groupCollection.doc(gid).collection("users").doc(uidToAdd).set({
      'user-ref': userCollection.doc(uidToAdd),
      'timestamp': ts,
      'zest-key': zestKey
    });
    // Update the group user count.
    await groupCollection
        .doc(gid)
        .update({'user-count': FieldValue.increment(1)});
    // Update the group reference in the user (the one being added) document.
    await userCollection.doc(uidToAdd).collection("groups").doc(gid).set({
      'group-ref': groupCollection.doc(gid),
      'timestamp': ts,
    });
    return "User added!";
  }

  // Handles when a user leaves a particular group.
  Future<void> leaveGroup(String gid) async {
    // Delete the user reference from the group.
    await groupCollection.doc(gid).collection("users").doc(uid).delete();
    // Delete the group reference from the user document.
    await userCollection.doc(uid).collection("groups").doc(gid).delete();
    // Check for capacity.
    QuerySnapshot cap =
        await groupCollection.doc(gid).collection("users").get();
    if (cap.docs.length <= 0) {
      QuerySnapshot allMatched =
          await groupCollection.doc(gid).collection("matched").get();
      for (QueryDocumentSnapshot doc in allMatched.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        await unmatchGroup(gid, data["group-ref"].id, doc.id);
      }
      // Delete the group if there are no users left in it.
      await groupCollection.doc(gid).delete();
      return;
    } else {
      // Otherwise just decrement the group user count.
      await groupCollection
          .doc(gid)
          .update({'user-count': FieldValue.increment(-1)});
    }
  }

  // Helper function for converting a group DocumentReference to a dart map.
  Future<Map<String, dynamic>> _groupRefToMap(
      DocumentReference groupRef) async {
    // Get snapshot of group doc reference.
    DocumentSnapshot snapshot = await groupRef.get();

    // Convert snapshot data into a dart map.
    final mapData = snapshot.data() as Map<String, dynamic>;

    // Add group reference to the dart map.
    mapData["group-ref"] = groupRef;
    return mapData;
  }

  // Handles the interactions a user conducts on a recommended match.
  Future<void> outgoingGroupInteraction(
      String gid, String yougid, bool requested) async {
    // Define timestamp and for the interaction
    DateTime ts = DateTime.now();

    // Get current user info
    Map<String, dynamic> currGroup =
        await _groupRefToMap(groupCollection.doc(gid));

    // Update requester's "outgoing" collection.
    await groupCollection
        .doc(gid)
        .collection("outgoing")
        .doc(yougid)
        .set({
          "timestamp": ts,
          "group-ref": groupCollection.doc(yougid),
          "requested": requested,
        })
        .then((value) => print(requested ? "Request sent." : "Denial sent."))
        .catchError((error) => print("Failed to send: $error"));

    // Delete from the requester's "recommendations" collection.
    await groupCollection
        .doc(gid)
        .collection("recommendations")
        .doc(yougid)
        .delete();

    // To avoid double matching, also delete from the requestee's "recommendations" collection (even if it is not there).
    await groupCollection
        .doc(yougid)
        .collection("recommendations")
        .doc(gid)
        .delete();

    // Update requestee's "incoming" collection if request is sent
    if (requested) {
      await groupCollection
          .doc(yougid)
          .collection("incoming")
          .doc(gid)
          .set({
            "timestamp": ts,
            "group-ref": groupCollection.doc(gid),
          })
          .then((value) => print("Incoming request received."))
          .catchError(
              (error) => print("Failed to receive incoming request: $error"));
    }
  }

  // Handles the interactions a user conducts on an incoming match request.
  Future<void> incomingGroupInteraction(
      String gid, String yougid, bool accepted) async {
    // Define timestamp and for the match
    DateTime ts = DateTime.now();

    // Update user's "matched" collection on acceptance.
    if (accepted) {
      // Create chat document (generated id is used to identify the match).
      DocumentReference chatRef = chatCollection.doc();
      await chatCollection
          .doc(chatRef.id)
          .set({
            "type": "group",
            "timestamp": ts,
            "group1-ref": groupCollection.doc(gid),
            "group2-ref": groupCollection.doc(yougid),
          })
          .then((value) => print("Chat created."))
          .catchError((error) => print("Failed to create chat: $error"));

      // Add users of both groups to the chat.
      QuerySnapshot users1 =
          await groupCollection.doc(gid).collection("users").get();
      QuerySnapshot users2 =
          await groupCollection.doc(yougid).collection("users").get();
      for (QueryDocumentSnapshot user in users1.docs) {
        chatRef.collection("users").doc(user.id).set({
          "user-ref": userCollection.doc(user.id),
        });
      }
      for (QueryDocumentSnapshot user in users2.docs) {
        chatRef.collection("users").doc(user.id).set({
          "user-ref": userCollection.doc(user.id),
        });
      }
      await groupCollection
          .doc(gid)
          .collection("matched")
          .doc(chatRef.id)
          .set({
            "timestamp": ts,
            "group-ref": groupCollection.doc(yougid),
            "chat-ref": chatRef,
          })
          .then((value) => print("Acceptance (initiator) sent."))
          .catchError((error) => print("Failed to send: $error"));
      await groupCollection
          .doc(yougid)
          .collection("matched")
          .doc(chatRef.id)
          .set({
            "timestamp": ts,
            "group-ref": groupCollection.doc(gid),
            "chat-ref": chatRef,
          })
          .then((value) => print("Acceptance (receiver) sent."))
          .catchError((error) => print("Failed to send: $error"));
    }

    // Delete the incoming request regardless of acceptance.
    await groupCollection
        .doc(gid)
        .collection("incoming")
        .doc(yougid)
        .delete()
        .then((value) => print("Incoming request deleted."))
        .catchError(
            (error) => print("Failed to delete incoming request: $error"));
  }

  // Stream to retrieve all partner info.
  Stream<QuerySnapshot> getPartners() {
    return partnerCollection.where('available', isEqualTo: true).snapshots();
  }

  // Function to record coupon redemption
  Future<void> redeemMetrics(String partnerid) async {
    await partnerCollection
        .doc(partnerid)
        .update({'count': FieldValue.increment(1)});
    DocumentSnapshot test = await userCollection
        .doc(uid)
        .collection('metrics')
        .doc(partnerid)
        .get();
    if (test.exists) {
      await userCollection
          .doc(uid)
          .collection('metrics')
          .doc(partnerid)
          .update({'count': FieldValue.increment(1)});
    } else {
      await userCollection
          .doc(uid)
          .collection('metrics')
          .doc(partnerid)
          .set({'count': 1});
    }
  }

  // Logging reports in the database.
  Future<void> report(String type, String reason,
      DocumentReference reporterUser, DocumentReference accused) async {
    await reportCollection
        .doc()
        .set({
          'accused-ref': accused,
          'reason': reason,
          'reported-by-ref': reporterUser,
          'reported-type': type,
          'timestamp': DateTime.now(),
        })
        .then((value) => print("Report added"))
        .catchError((error) => print(error.toString()));
  }
}
