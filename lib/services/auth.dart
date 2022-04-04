import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';

// Authentication class:
//  Contains all methods and data pertaining to user authentication.
class AuthService {
  // Instantiate FirebaseAuth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream that listens for authentication changes.
  Stream<User?> user() {
    return _auth.authStateChanges();
  }

  // Method for signing up.
  Future<int> signUp(String email, String password) async {
    try {
      // Obtain User object (FireAuth function).
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Store in database.
      await DatabaseService(uid: user!.uid).createUser();
      await DatabaseService(uid: user.uid).userCollection.doc(user.uid).collection('metrics').doc('eljefes-first').set({'count': 0});

      // Return 0 on success.
      return 0;
    } catch (e) {
      // Return 1 on error.
      return 1;
    }
  }

  // Method for singing in (returns status as int).
  Future<int> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Return 0 on success.
      return 0;
    } catch (error) {
      // Return 1 on error.
      return 1;
    }
  }

  // Method for signing out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Method for deleting a user.
  Future<int> deleteUser(String email, String password) async {
    try {
      // Retrieve current user info
      User currUser = _auth.currentUser!;
      // Input reauthentication data
      AuthCredential credentials =
          EmailAuthProvider.credential(email: email, password: password);
      // Attempt to reauthenticate (invalid credentials results in a sign out event)
      UserCredential result =
          await currUser.reauthenticateWithCredential(credentials);
      // Delete user data from Firestore
      await DatabaseService(uid: result.user!.uid).deleteUser();
      // Delete from Firebase Auth and logout
      await currUser.delete();
      // Success status
      return 0;
    } catch (e) {
      // Error status
      return 1;
    }
  }

  // Method for sending password reset email.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
