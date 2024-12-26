import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zovcord/core/model/user_model.dart';

// Класс для работы с аутентификацией и пользовательскими данными
class AuthServices {
  // Инициализация сервисов Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Получение текущего авторизованного пользователя
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Метод входа пользователя
  Future<void> signIn(String email, String password) async {
    try {
      // Авторизация пользователя через Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Проверка существования документа пользователя в Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('Users')
          .doc(userCredential.user!.uid)
          .get();

      // Если документ не существует - создаем новый
      if (!userDoc.exists) {
        final user = UserModel(
          id: userCredential.user!.uid,
          email: email,
          nickname: '',
          isDarkTheme: false,
          isOnline: true,
          theme: 1,
        );
        await _firestore.collection('Users').doc(user.id).set(user.toMap());
      } else {
        // Если существует - обновляем статус онлайн
        await updateUserStatus(true);
      }
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  // Метод выхода пользователя
  Future<void> signOut() async {
    try {
      await updateUserStatus(false); // Установка статуса оффлайн
      await _auth.signOut();
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  // Метод регистрации нового пользователя
  Future<void> signUp(String email, String password) async {
    try {
      // Создание нового пользователя в Firebase Auth
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Создание документа пользователя в Firestore
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email,
        nickname: '', // Пустой никнейм по умолчанию
        isDarkTheme: false,
        isOnline: true,
        theme: 1,
      );
      await _firestore.collection('Users').doc(user.id).set(user.toMap());
    } on FirebaseAuthException catch (ex) {
      throw Exception(ex.message);
    }
  }

  // Метод обновления статуса пользователя (онлайн/оффлайн)
  Future<void> updateUserStatus(bool isOnline) async {
    try {
      final user = getCurrentUser();
      if (user != null) {
        await _firestore.collection('Users').doc(user.uid).update({
          'isOnline': isOnline,
        });
      }
    } catch (e) {
      throw Exception('Ошибка обновления статуса пользователя: $e');
    }
  }
}
