import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/theme/styles/app_text_styles.dart';
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
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text(
          "Настройки",
          style: AppTextStyles.appbar1,
        ),
      ),
      body: Center(
        child: Container(
          width: 600,
          height: 700,
          child: Column(
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
                      Navigator.of(context).pushReplacementNamed('/login');
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
