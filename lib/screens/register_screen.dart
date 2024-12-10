import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.callBack});
  final VoidCallback? callBack;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthServices _authServices = locator.get();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> signUp(String email, String password) async {
    try {
      showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await _authServices.signUp(email, password);
      await _authServices.signIn(email, password);
      if (!mounted) return;
      Navigator.pop(context);
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Регистрация',
                style: TextStyle(fontSize: 24),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(hintText: "Почта"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(hintText: "Пароль"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await signUp(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                },
                child: const Text("Зарегистрироваться"),
              ),
              if (widget.callBack != null)
                TextButton(
                  onPressed: widget.callBack,
                  child: const Text("Войти"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
