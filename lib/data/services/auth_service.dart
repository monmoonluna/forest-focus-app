import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      if (userCredential.user != null) {
        print("Signed in anonymously with UID: ${userCredential.user!.uid}");
      } else {
        print("Failed to sign in anonymously: UserCredential is null");
      }
    } catch (e) {
      print('Error signing in anonymously: $e');
      rethrow;
    }
  }
}