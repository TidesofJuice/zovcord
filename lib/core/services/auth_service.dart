import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServices {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthServices(this._auth, this._firestore);

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> updateUserStatus(bool isOnline) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('Users').doc(user.uid).update({
        'isOnline': isOnline,
      });
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await updateUserStatus(true); // Обновление статуса на онлайн
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  Future<void> signOut() async {
    await updateUserStatus(false);
    await _auth.signOut();
  }

  Future<void> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      await _firestore.collection('Users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'isDarkTheme': false,
        'isOnline': true,
      });
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }
}
