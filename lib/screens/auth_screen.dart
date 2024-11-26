// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  String _email = '';
  String _password = '';
  bool _isLoading = false;
  bool _isLogin = true;

  void _submitAuthForm() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // Вход
        await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      } else {
        // Регистрация
        await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );
      }
      Navigator.pushReplacementNamed(context, '/chat');
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Вход' : 'Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Почта'),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _email = value,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
              onChanged: (value) => _password = value,
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _submitAuthForm,
                child: Text(_isLogin ? 'Войти' : 'Зарегистрироваться'),
              ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() => _isLogin = !_isLogin);
              },
              child: Text(_isLogin
                  ? 'Нет аккаунта? Зарегистрироваться'
                  : 'Уже есть аккаунт? Войти'),
            ),
          ],
        ),
      ),
    );
  }
}
