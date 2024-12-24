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
        context.go('/chatlist');
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
      body: BackgroundImage(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 200),
              const Text(
                'ZOVCORD',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(
                width: 400,
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Почта',
                        fillColor: Color.fromARGB(255, 139, 121, 255),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        fillColor: Color.fromARGB(255, 139, 121, 255),
                        filled: true,
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle:
                            const TextStyle(color: Colors.black, fontSize: 20),
                        minimumSize: const Size(400, 50),
                        backgroundColor:
                            Colors.white,
                        overlayColor: Colors.black,
                      ),
                      onPressed: () async {
                        await signUp(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      child: const Text(
                        'Зарегистрироваться',
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text(
                        'Войти',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  final Widget child;

  BackgroundImage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/pic/flag.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
