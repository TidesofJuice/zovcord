import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authService = locator.get<AuthServices>();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Настройки"),
      ),
      body: Column(
        children: [
          if (user != null)
            ListTile(
              title: const Text("Почта"),
              subtitle: Text(user.email ?? "Ошибка"),
            ),
          ListTile(
            title: const Text("Темная тема"),
            trailing: Switch(
              value: themeProvider.currentTheme == ThemeData.dark(),
              onChanged: (_) {
                themeProvider.toggleTheme();
              },
            ),
          ),
          ListTile(
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
    );
  }
}
