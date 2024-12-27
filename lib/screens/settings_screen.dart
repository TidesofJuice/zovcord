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
  final TextEditingController nicknameController = TextEditingController();
  String? currentNickname;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentNickname();
  }

  Future<void> _loadCurrentNickname() async {
    final user = authService.getCurrentUser();
    if (user != null) {
      final nickname = await chatRepository.getCurrentNickname(user.uid);
      setState(() {
        currentNickname = nickname;
        nicknameController.text = nickname ?? '';
      });
    }
  }

  Future<void> _updateNickname() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await chatRepository.updateNickname(
        authService.getCurrentUser()!.uid,
        nicknameController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Никнейм обновлен')),
      );
      setState(() {
        currentNickname = nicknameController.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления никнейма: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/chatlist');
          },
        ),
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentNickname != null)
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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
              SizedBox(height: 20),
              TextField(
                controller: nicknameController,
                decoration: const InputDecoration(labelText: 'Никнейм'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _updateNickname,
                      child: const Text('Обновить никнейм'),
                    ),
              if (user != null)
                ListTile(
                  title: const Text("Почта"),
                  leading: IconTheme(
                      data: Theme.of(context).iconTheme,
                      child: Icon(Icons.mail)),
                  subtitle: Text(user.email ?? "Ошибка"),
                ),
              ListTile(
                title: const Text("Темы"),
                trailing: PopupMenuButton<int>(
                  onSelected: (value) {
                    themeProvider.toggleTheme(value);
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
              ListTile(
                iconColor: Theme.of(context).iconTheme.color,
                title: const Text("Выйти"),
                trailing: IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      context.go('/login');
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
