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
  // Получение экземпляра AuthServices через локатор
  final AuthServices _authServices = locator.get();
  // Контроллеры для ввода email и пароля
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Метод для выполнения регистрации
  Future<void> signUp(String email, String password) async {
    try {
      // Показ индикатора загрузки
      showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      // Выполнение регистрации пользователя
      await _authServices.signUp(email, password);
      // Вход после успешной регистрации
      await _authServices.signIn(email, password);

      if (!mounted) return; // Проверка, что контекст доступен
      Navigator.pop(context); // Закрытие диалога загрузки
      if (context.mounted) {
        // Переход на экран списка чатов
        context.go('/chatlist');
      }
    } catch (e) {
      Navigator.pop(context); // Закрытие диалога загрузки при ошибке
      // Показ ошибки в диалоговом окне
      showDialog(
        context: context,
        builder: (_) => AlertDialog(content: Text(e.toString())),
      );
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
                'ZOVCORD', // Название приложения
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              SizedBox(
                width: 400, // Ширина блока с формой
                child: Column(
                  children: [
                    // Поле ввода email
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Почта',
                        fillColor: Color.fromARGB(255, 139, 121, 255),
                        filled: true, // Фон поля ввода
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Поле ввода пароля
                    TextField(
                      controller: passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        fillColor: Color.fromARGB(255, 139, 121, 255),
                        filled: true, // Фон поля ввода
                      ),
                      obscureText: true, // Скрытие символов пароля
                    ),
                    const SizedBox(height: 20),
                    // Кнопка регистрации
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        textStyle:
                            const TextStyle(color: Colors.black, fontSize: 20),
                        minimumSize: const Size(400, 50), // Размер кнопки
                        backgroundColor: Colors.white, // Цвет фона кнопки
                        overlayColor: Colors.black, // Цвет при нажатии
                      ),
                      onPressed: () async {
                        // Выполнение регистрации
                        await signUp(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      child: const Text(
                        'Зарегистрироваться', // Текст на кнопке
                        style: TextStyle(fontSize: 24, color: Colors.black),
                      ),
                    ),
                    // Кнопка перехода на экран входа
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

// Виджет для фона с изображением
class BackgroundImage extends StatelessWidget {
  final Widget child;

  BackgroundImage({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ширина на весь экран
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
