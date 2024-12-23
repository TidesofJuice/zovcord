import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/theme/styles/app_text_styles.dart';
import 'package:zovcord/core/repository/chat_repository.dart';

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
      body: const UserList(),
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
        height: 700,
        child: StreamBuilder(
          stream: _chatRepository.getUserStream(),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final users = snapshot.data!.docs;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                final data = user.data() as Map<String, dynamic>;

                if (!data.containsKey('email') || !data.containsKey('uid')) {
                  return const SizedBox.shrink();
                }

                final email = data['email'];
                final userId = data['uid'];
                final bool isOnline = data['is_online'] ?? false;

                return UserTile(
                  email: email,
                  userId: userId,
                  isOnline: isOnline,
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
  const UserTile({super.key, required this.email, required this.userId, required this.isOnline});

  final String? email;
  final String? userId;
  final bool isOnline;

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
        subtitle: Text(isOnline ? "Online" : "Offline", style: TextStyle(color: isOnline ? Colors.green : Colors.red)),
        onTap: () {
          context.go('/chat/$email/$userId');
        },
      );
    }
    return const SizedBox.shrink();
  }
}
