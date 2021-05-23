import 'package:firebase_auth/firebase_auth.dart';
import 'package:zesti/services/database.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  Future<String> signUp(email, password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user == null) {
        return "Error";
      }
      await DatabaseService(uid: user.uid).updateUserData("");
      return "Signed Up";
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> signIn(email, password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed In";
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }
}
