import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthServices(this._auth, this._firestore);

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    try {} on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'isDarkTheme': false,
      });
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }
}
