import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zovcord/core/model/user_model.dart';

class AuthServices {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthServices(this._auth, this._firestore);

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (ex) {
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
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        isDarkTheme: false,
      );
      await _firestore.collection('Users').doc(user.id).set(user.toMap());
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }
}
