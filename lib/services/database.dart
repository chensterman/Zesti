import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zesti/models/zestiuser.dart';

// DatabaseService class:
//  Contains all methods and data pertaining to the user database.
class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  // Access to 'users' collection.
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

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

  // Stream to show list of matched users
  Stream<Future<List<ZestiUser>>> get matches {
    return userCollection
        .doc(uid)
        .collection('matches')
        .snapshots()
        .map(_zestiUserFromSnapshot);
  }

  // Helper function for matched users stream - convert QuerySnapshot to
  // list of ZestiUser models. SOMETHING HERE IS WRONG.
  Future<List<ZestiUser>> _zestiUserFromSnapshot(QuerySnapshot snapshot) async {
    List<dynamic> refList = snapshot.docs.map((doc) {
      return doc.get('user-ref');
    }).toList();
    List<ZestiUser> matchedList = [];
    for (DocumentReference ref in refList) {
      DocumentSnapshot data = await ref.get();
      matchedList.add(ZestiUser(
          designation: 'Test',
          mutualFriends: 69,
          name: data.get('first-name'),
          age: 69,
          imgUrl: data.get('photo-ref'),
          location: 'Test',
          bio: data.get('bio')));
    }
    return matchedList;
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

  // Get user info from document fields.
  Future<Object?> getInfo() async {
    DocumentSnapshot doc = await userCollection.doc(uid).get();
    return doc.data();
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
}
