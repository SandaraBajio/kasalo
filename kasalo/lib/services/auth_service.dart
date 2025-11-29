import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Stream to listen to auth changes (Are we logged in or out?)
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // 2. Register with Email & Password
  // Requirements: Source [18] (Input Details) & Source [19] (Firebase Registration)
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Registration Error: ${e.toString()}");
      return null;
    }
  }

  // 3. Login with Email & Password
  // Requirements: Source [23] (Submit Login)
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login Error: ${e.toString()}");
      return null;
    }
  }

  // 4. Sign Out
  // Requirements: Source [31] (System Logout)
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print("Logout Error: ${e.toString()}");
      return null;
    }
  }
}