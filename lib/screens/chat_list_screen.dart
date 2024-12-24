import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:zovcord/core/model/user_model.dart';

final AuthServices _authServices = locator.get();
final ChatRepository _chatRepository = locator.get();

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

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
        child: const UserList(),
      ),
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
        child: StreamBuilder<List<UserModel>>(
          stream: _chatRepository.getUserStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              print('Ошибка: ${snapshot.error}');
              return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
            }

            final users = snapshot.data ?? [];
            
            if (users.isEmpty) {
              return const Center(child: Text('Нет доступных пользователей'));
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return UserTile(
                  email: user.email,
                  userId: user.id,
                  isOnline: user.isOnline,
                  nickname: user.nickname,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  const UserTile({
    super.key, 
    required this.email, 
    required this.userId, 
    required this.isOnline,
    this.nickname,
  });

  final String email;
  final String userId;
  final bool isOnline;
  final String? nickname;

  @override
  Widget build(BuildContext context) {
    final currentUser = _authServices.getCurrentUser();
    final displayName = nickname?.isNotEmpty == true ? nickname! : email;
    
    if (currentUser != null && email != currentUser.email) {
      return ListTile(
        shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(24)),
        hoverColor: Theme.of(context).colorScheme.tertiary,
        textColor: Theme.of(context).colorScheme.onSecondary,
        leading: IconTheme(
          data: Theme.of(context).iconTheme,
          child: const Icon(Icons.person),
        ),
        title: Text(displayName),
        subtitle: Text(
          isOnline ? "Online" : "Offline",
          style: TextStyle(
            color: isOnline ? Colors.green : Colors.red
          ),
        ),
        onTap: () {
          final encodedEmail = Uri.encodeComponent(email);
          context.go('/chat-with/$encodedEmail/$userId');
        },
      );
    }
    return const SizedBox.shrink();
  }
}
