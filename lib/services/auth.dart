import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';

// AuthService class:
//  Contains all methods and data pertaining to user authentication.
class AuthService {
  // Instantiate FirebaseAuth.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream that listens for authentication changes.
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Method for signing up.
  Future<void> signUp(email, password) async {
    try {
      // Obtain User object (FireAuth function).
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      // Check for null-user error.
      if (user == null) {
        print("Error");
        return;
      }

      // Store in database.
      await DatabaseService(uid: user.uid).createUser();
      print("Signed Up");
    } catch (e) {
      print(e.toString());
    }
  }

  // Method for singing in.
  Future<void> signIn(email, password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      print("Signed In");
    } catch (e) {
      print(e.toString());
    }
  }

  // Method for signing out.
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
