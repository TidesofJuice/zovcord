import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/chat_service.dart';
import 'package:zovcord/core/theme/styles/app_text_styles.dart';

final ChatService _chatService = locator.get();
final AuthServices _authServices = locator.get();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text("Список чатов", style: AppTextStyles.appbar1),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              shadows: [
                Shadow(
                    // bottomLeft
                    offset: Offset(-1, -1),
                    color: Colors.black),
                Shadow(
                    // bottomRight
                    offset: Offset(1, -1),
                    color: Colors.black),
                Shadow(
                    // topRight
                    offset: Offset(1, 1),
                    color: Colors.black),
                Shadow(
                    // topLeft
                    offset: Offset(-1, 1),
                    color: Colors.black),
              ],
            ),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: UserList(),
    );
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: ShapeDecoration(
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        width: 1000,
        height: 700,
        child: StreamBuilder(
          stream: _chatService.getuserStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text("Ошибка загрузки пользователей"));
            }
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: Text("ЗАГРУЗКА..."));
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
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.email, required this.userId});

  final String? email;
  final String? userId;

  @override
  Widget build(BuildContext context) {
    if (email != null &&
        userId != null &&
        email != _authServices.getCurrentUser()!.email) {
      return ListTile(
        leading: const Icon(Icons.person),
        title: Text(email!),
        onTap: () {
          context.go('/chat/$email/$userId');
        },
      );
    }
    return const SizedBox.shrink();
  }
}
