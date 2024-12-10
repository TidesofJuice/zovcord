import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/theme/theme_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.callBack});
  final VoidCallback? callBack;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthServices _authServices = locator.get();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  final image = AssetImage('images/logo.jpg');

  Future<void> signIn(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authServices.signIn(email, password);
      if (context.mounted) {
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        await themeProvider.reloadTheme();
        context.go('/home');
      }
    } catch (e) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text(e.toString())),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
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
                'Войти',
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
                onPressed: _isLoading
                    ? null
                    : () async {
                        await signIn(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text("Войти"),
              ),
              if (widget.callBack != null)
                TextButton(
                  onPressed: widget.callBack,
                  child: const Text("Зарегистрироваться"),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
