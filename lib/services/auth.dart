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
  Future<int> signUp(
      String email, String password, Function errorCallback) async {
    try {
      // Obtain User object (FireAuth function).
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Store in database.
      await DatabaseService(uid: user!.uid).createUser();

      // Return 0 on success.
      return 0;
    } catch (e) {
      // Run the callback function to display the error.
      errorCallback();
      // Return 1 on error.
      return 1;
    }
  }

  // Method for singing in (returns status as int).
  Future<int> signIn(
      String email, String password, Function errorCallback) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Return 0 on success.
      return 0;
    } catch (error) {
      // Run the callback function to display the error.
      errorCallback();
      // Return 1 on error.
      return 1;
    }
  }

  // Method for signing out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Method for deleting a user.
  Future<void> deleteUser() async {
    User currUser = _auth.currentUser!;
    await DatabaseService(uid: currUser.uid).deleteUser();
    await _auth.currentUser!.delete();
  }

  // Method for sending password reset email.
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
