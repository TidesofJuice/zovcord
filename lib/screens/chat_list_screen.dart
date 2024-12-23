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
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: Theme.of(context).appBarTheme.iconTheme,
        title: Text("Список чатов",
            style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: [
          IconButton(
            style: ButtonStyle(
              iconColor: WidgetStateProperty.all(
                  Theme.of(context).colorScheme.onPrimary),
            ),
            icon: const Icon(
              Icons.settings,
            ),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: UserList()),
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
        height: 600,
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
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(24)),
        hoverColor: Theme.of(context).colorScheme.tertiary,
        textColor: Theme.of(context).colorScheme.onSecondary,
        leading: IconTheme(
          data: Theme.of(context).iconTheme,
          child: const Icon(Icons.person),
        ),
        title: Text(email!),
        onTap: () {
          context.go('/chat/$email/$userId');
        },
      );
    }
    return const SizedBox.shrink();
  }
}
