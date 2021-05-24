import 'package:cloud_firestore/cloud_firestore.dart';

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
          'dating-identity': null,
          'dating-interest': null,
          'bio': null,
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
  Future<void> updateBirthday(Timestamp birthday) async {
    await userCollection
        .doc(uid)
        .update({'birthday': birthday})
        .then((value) => print("Birthday Updated"))
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

  // Update user bio.
  Future<void> updateBio(String bio) async {
    await userCollection
        .doc(uid)
        .update({'bio': bio})
        .then((value) => print("Bio Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
}
