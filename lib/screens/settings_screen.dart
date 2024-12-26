import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/theme/theme_provider.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:go_router/go_router.dart';

// Получаем экземпляры сервисов аутентификации и репозитория чатов
final AuthServices authService = locator.get();
final ChatRepository chatRepository = locator.get();

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Контроллер для текстового поля ввода никнейма
  final TextEditingController nicknameController = TextEditingController();
  String? currentNickname; // Текущий никнейм пользователя
  bool _isLoading = false; // Индикатор загрузки

  @override
  void initState() {
    super.initState();
    _loadCurrentNickname(); // Загружаем текущий никнейм при инициализации
  }

  // Метод для загрузки текущего никнейма пользователя
  Future<void> _loadCurrentNickname() async {
    final user = authService.getCurrentUser(); // Получаем текущего пользователя
    if (user != null) {
      // Если пользователь существует, загружаем никнейм из репозитория
      final nickname = await chatRepository.getCurrentNickname(user.uid);
      setState(() {
        currentNickname = nickname;
        nicknameController.text =
            nickname ?? ''; // Устанавливаем текст в контроллере
      });
    }
  }

  // Метод для обновления никнейма
  Future<void> _updateNickname() async {
    setState(() {
      _isLoading = true; // Включаем индикатор загрузки
    });
    try {
      // Обновляем никнейм в репозитории
      await chatRepository.updateNickname(
        authService.getCurrentUser()!.uid,
        nicknameController.text,
      );
      // Показываем сообщение об успешном обновлении
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Никнейм обновлен')),
      );
      setState(() {
        currentNickname =
            nicknameController.text; // Обновляем локальный никнейм
      });
    } catch (e) {
      // Показываем сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления никнейма: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Выключаем индикатор загрузки
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        Provider.of<ThemeProvider>(context); // Получаем провайдер темы
    final user = authService.getCurrentUser(); // Получаем текущего пользователя

    return Scaffold(
      appBar: AppBar(
        // Настройки верхнего приложения
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Настройки'),
        leading: IconButton(
          // Кнопка возврата на предыдущий экран
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/chatlist');
          },
        ),
      ),
      body: Center(
        // Основное содержимое экрана
        child: Container(
          width: 600, // Ширина контейнера
          height: 700, // Высота контейнера
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Выравнивание по центру
            children: [
              if (currentNickname != null)
                // Отображение текущего никнейма
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15), // Скругление углов
                  ),
                  tileColor: Theme.of(context).colorScheme.primary,
                  title: Text(
                    "Текущий никнейм",
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  subtitle: Text(
                    currentNickname!,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              // Поле ввода никнейма
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Никнейм'),
              ),
              const SizedBox(height: 20), // Отступ между элементами
              _isLoading
                  // Показать индикатор загрузки или кнопку
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateNickname,
                      child: const Text('Обновить никнейм'),
                    ),
              if (user != null)
                // Отображение почты пользователя
                ListTile(
                  title: const Text("Почта"),
                  leading: IconTheme(
                      data: Theme.of(context).iconTheme,
                      child: Icon(Icons.mail)),
                  subtitle: Text(user.email ?? "Ошибка"),
                ),
              // Выбор темы
              ListTile(
                title: const Text("Темы"),
                trailing: PopupMenuButton<int>(
                  onSelected: (value) {
                    themeProvider.toggleTheme(value); // Переключение темы
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Text('Light theme'),
                      value: 1,
                    ),
                    PopupMenuItem(
                      child: const Text('Dark theme'),
                      value: 2,
                    ),
                    PopupMenuItem(
                      child: const Text('Violet theme'),
                      value: 3,
                    ),
                    PopupMenuItem(
                      child: const Text('Pink theme'),
                      value: 4,
                    ),
                  ],
                  icon: Icon(Icons.brush),
                  tooltip: "Выбор темы",
                ),
              ),
              // Кнопка выхода из аккаунта
              ListTile(
                iconColor: Theme.of(context).iconTheme.color,
                title: const Text("Выйти"),
                trailing: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authService.signOut(); // Выход из аккаунта
                    if (context.mounted) {
                      context.go('/login'); // Переход на экран входа
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
