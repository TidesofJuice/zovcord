import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zovcord/core/model/user_model.dart';

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
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
    try {
      await updateUserStatus(false); // Обновление статуса на оффлайн
      await _auth.signOut();
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        nickname: '', // Изначально пустой никнейм
        isDarkTheme: false,
        isOnline: true,
        theme: 1,
      );
      await _firestore.collection('Users').doc(user.id).set(user.toMap());
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).update({
          'is_online': isOnline,
        });
      }
    } catch (e) {
      throw Exception('Ошибка обновления статуса пользователя: $e');
    }
  }
}
