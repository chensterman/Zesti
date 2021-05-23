import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  Future updateUserData(String bio) async {
    return await userCollection
        .doc(uid)
        .set({'bio': bio})
        .then((value) => print("User added"))
        .catchError((error) => print("Failed"));
  }
}
