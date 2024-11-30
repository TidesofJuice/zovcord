import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/cubit/auth_cubit.dart';
import '../core/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat), // Chats icon
            onPressed: () {
              GoRouter.of(context).go('/chat'); // Navigate back to chats
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return Text('Email: ${state.user?.email ?? "Не вошел"}');
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<AuthCubit>().logout();
                GoRouter.of(context).go('/login'); // Redirect to login after logout
              },
              child: const Text('Выйти'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                themeProvider.toggleTheme();
              },
              child: Text(themeProvider.currentTheme == ThemeData.light()
                  ? 'Сменить на темную тему'
                  : 'Сменить на светлую тему'),
            ),
          ],
        ),
      ),
    );
  }
}