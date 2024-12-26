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
  // Получение экземпляра AuthServices через локатор
  final AuthServices _authServices = locator.get();
  // Контроллеры для ввода email и пароля
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false; // Флаг загрузки для индикации состояния

  // Метод для выполнения входа
  Future<void> signIn(String email, String password) async {
    setState(() {
      _isLoading = true; // Устанавливаем состояние загрузки
    });

    try {
      // Попытка входа с использованием введенных данных
      await _authServices.signIn(email, password);
      if (context.mounted) {
        // Если вход успешен, обновляем тему и переходим на список чатов
        final themeProvider =
            Provider.of<ThemeProvider>(context, listen: false);
        await themeProvider.reloadTheme();
        context.go('/chatlist');
      }
    } catch (e) {
      if (context.mounted) {
        // В случае ошибки показываем сообщение пользователю
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text(e.toString())),
        );
      }
    } finally {
      // Сбрасываем состояние загрузки
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Основной экран с фоновым изображением
      body: BackgroundImage(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 200), // Отступ сверху
              const Text(
                'ZOVCORD', // Заголовок приложения
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 400, // Ширина блока с полями ввода и кнопками
                child: Column(
                  children: [
                    // Поле ввода email
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Почта',
                        fillColor: Color.fromARGB(255, 139, 121, 255),
                        filled: true,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Поле ввода пароля
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        fillColor: Color.fromARGB(255, 139, 121, 255),
                        filled: true,
                      ),
                      obscureText: true, // Скрытие символов пароля
                    ),
                    const SizedBox(height: 20),
                    // Кнопка входа
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle:
                            const TextStyle(color: Colors.black, fontSize: 20),
                        minimumSize: const Size(400, 50), // Размер кнопки
                        backgroundColor: Colors.white, // Цвет фона
                        overlayColor: Colors.black, // Цвет при нажатии
                      ),
                      onPressed: _isLoading
                          ? null // Отключение кнопки, если идет загрузка
                          : () async {
                              // Выполнение входа
                              await signIn(
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            },
                      child: _isLoading
                          ? const CircularProgressIndicator() // Индикатор загрузки
                          : const Text(
                              'Войти', // Текст кнопки
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                    ),
                    const SizedBox(height: 20),
                    // Кнопка перехода на экран регистрации
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text(
                        'Зарегистрироваться',
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

// Виджет для фона с изображением
class BackgroundImage extends StatelessWidget {
  final Widget child;

  BackgroundImage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ширина контейнера на весь экран
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        // Установка фонового изображения
        image: DecorationImage(
          image: AssetImage("assets/pic/flag.jpg"),
          fit: BoxFit.cover, // Растяжение изображения на весь экран
        ),
      ),
      child: child, // Содержимое поверх фона
    );
  }
}
