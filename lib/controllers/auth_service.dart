import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  //create account with email and passoword
  Future<String> createAccountWithEmail(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return 'success';
    } on FirebaseAuthException catch (e) {
      return e.message.toString();

      // print(e.toString());
    }
  }

  //login  with email and passoword
  Future<String> loginInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return 'login successfully';
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
      // print(e.toString());
    }
  }

  //logout out
  Future<void> logout() async {
    await _auth.signOut();
  }

  //reseting the password
  Future<String> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Mail sent';
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  //check whether the user is logged in
  Future<bool> isLoggedIn() async {
    final user = _auth.currentUser;
    return user != null;
  }
}
