import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/chat_service.dart';

final ChatService _chatService = locator.get();
final AuthServices _authServices = locator.get();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Список чатов"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: const UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatService.getuserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Ошибка загрузки пользователей"));
        }
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Загрузка"));
        }
        return ListView(
          children: snapshot.data!
              .map<Widget>(
                (userData) => UserTile(
                  email: userData["email"],
                  userId: userData["uid"],
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.email, required this.userId});

  final String email;
  final String userId;

  @override
  Widget build(BuildContext context) {
    if (email != _authServices.getCurrentUser()!.email) {
      return ListTile(
        title: Text(email),
        onTap: () {
          context.go('/chat/$email/$userId');
        },
      );
    }
    return const SizedBox.shrink();
  }
}
