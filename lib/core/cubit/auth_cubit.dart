import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? errorMessage;

  bool get isAuthenticated => user != null;

  AuthState({this.user, this.isLoading = false, this.errorMessage});

  AuthState copyWith({User? user, bool? isLoading, String? errorMessage}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthState(user: FirebaseAuth.instance.currentUser)) {
    // Listen to authentication state changes
    _firebaseAuth.authStateChanges().listen((User? user) {
      emit(state.copyWith(user: user));
    });
  }

  Future<void> login(String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      emit(state.copyWith(user: userCredential.user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false, 
        errorMessage: _parseFirebaseError(e)
      ));
    }
  }

  Future<void> register(String email, String password) async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user email to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
      });

      emit(state.copyWith(user: userCredential.user, isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false, 
        errorMessage: _parseFirebaseError(e)
      ));
    }
  }

  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
      emit(state.copyWith(user: null, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: _parseFirebaseError(e)));
    }
  }

  // Helper method to parse Firebase error messages
  String _parseFirebaseError(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Пользователь не найден';
        case 'wrong-password':
          return 'Неверный пароль';
        case 'email-already-in-use':
          return 'Электронная почта уже используется';
        case 'weak-password':
          return 'Слишком слабый пароль';
        default:
          return 'Ошибка аутентификации: ${error.message}';
      }
    }
    return 'Произошла неизвестная ошибка';
  }
}