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
        context.go('/chatlist');
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
      body: BackgroundImage(
        child: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 100),
                const Text(
                  'ZOVCORD',
                  style: TextStyle(fontSize: 24, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: 400,
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            labelText: 'Почта',
                            labelStyle: TextStyle(color: Colors.black),
                            fillColor: Color.fromARGB(255, 139, 121, 255),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: passwordController,
                          cursorColor: Colors.black,
                          decoration: const InputDecoration(
                            labelText: 'Пароль',
                            fillColor: Color.fromARGB(255, 139, 121, 255),
                            filled: true,
                            labelStyle: TextStyle(color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.black),
                            ),
                          ),
                          style: TextStyle(color: Colors.black),
                          obscureText: true,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                                color: Colors.black, fontSize: 20),
                            minimumSize: const Size(400, 50),
                            backgroundColor: Colors.white,
                            overlayColor: Colors.black,
                          ),
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  await signIn(
                                    emailController.text.trim(),
                                    passwordController.text.trim(),
                                  );
                                },
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.black,
                                )
                              : const Text(
                                  'Войти',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                        ),
                        const SizedBox(height: 5),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text(
                            'Зарегистрироваться',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
