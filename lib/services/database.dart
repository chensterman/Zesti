import 'package:cloud_firestore/cloud_firestore.dart';

// DatabaseService class:
//  Contains all methods and data pertaining to the user database.
class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  // CreateUser
  //  Create user based on metadata
  Future createUser() async {
    return await userCollection
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

  Future updateAccountSetup() async {
    return await userCollection.doc(uid).update({'account-setup': true});
  }

  Future updateName(String first, String last) async {
    return await userCollection
        .doc(uid)
        .update({'first-name': first, 'last-name': last})
        .then((value) => print("Name Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future updateBirthday(Timestamp birthday) async {
    return await userCollection
        .doc(uid)
        .update({'birthday': birthday})
        .then((value) => print("Birthday Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future updateDatingIdentity(String identity) async {
    return await userCollection
        .doc(uid)
        .update({'dating-identity': identity})
        .then((value) => print("Identity Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future updateDatingInterest(String interest) async {
    return await userCollection
        .doc(uid)
        .update({'dating-identity': interest})
        .then((value) => print("Interest Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  Future updateBio(String bio) async {
    return await userCollection
        .doc(uid)
        .update({'bio': bio})
        .then((value) => print("Bio Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }
}
