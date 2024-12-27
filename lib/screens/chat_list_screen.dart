import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:zovcord/core/model/group_chat_model.dart';
import 'package:zovcord/core/model/user_model.dart';

final AuthServices _authServices = locator.get();
final ChatRepository _chatRepository = locator.get();

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = _authServices.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Чаты'),
      ),
      body: StreamBuilder<List<GroupChatModel>>(
        stream: _chatRepository.getChats(currentUser!.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                title: Text(chat.name),
                subtitle: Text(chat.lastMessage ?? 'Нет сообщений'),
                onTap: () {
                  context.push('/chat/${chat.chatId}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/creategroupchat');
        },
        child: const Icon(Icons.group_add),
        tooltip: 'Создать групповой чат',
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List<UserModel>>(
      stream: _chatRepository.searchUsers(query),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = snapshot.data!;
        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return ListTile(
              title: Text(user.nickname ?? user.email),
              subtitle: Text(user.email),
              onTap: () {
                final encodedEmail = Uri.encodeComponent(user.email);
                context.go('/chat-with/$encodedEmail/${user.id}');
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

class UserList extends StatelessWidget {
  const UserList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<List<UserModel>>(
        stream: _chatRepository.getUserStreamWithLastMessage(),
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

          return ListView.separated(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];

              return UserTile(
                email: user.email,
                userId: user.id,
                isOnline: user.isOnline,
                nickname: user.nickname,
                lastMessage: user.lastMessage,
                lastMessageTime: user.lastMessageTime,
              );
            },
            separatorBuilder: (context, index) => Divider(
              color: Theme.of(context).colorScheme.primary,
              thickness: 1,
            ),
          );
        },
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
    this.lastMessage,
    this.lastMessageTime,
    this.lastMessageSender,
  });

  final String email; // Электронная почта пользователя
  final String userId; // Идентификатор пользователя
  final bool isOnline; // Статус онлайн/офлайн
  final String? nickname; // Никнейм пользователя
  final String? lastMessage; // Последнее сообщение
  final Timestamp? lastMessageTime; // Время последнего сообщения
  final String? lastMessageSender; // Отправитель последнего сообщения

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    final now = DateTime.now();
    if (date.day == now.day) {
      return DateFormat('HH:mm').format(date);
    }
    return DateFormat('dd.MM HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authServices.currentUser;
    final displayName = nickname?.isNotEmpty == true ? nickname! : email;

    if (currentUser != null && email != currentUser.email) {
      return ListTile(
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(24)),
        hoverColor: Theme.of(context).colorScheme.tertiary,
        textColor: Theme.of(context).colorScheme.onSecondary,
        leading: IconTheme(
          data: Theme.of(context).iconTheme,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Stack(
              children: [
                Icon(Icons.person),
                if (isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green,
                      ),
                    ),
                  ),
                if (!isOnline)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        title: Text(
          (displayName),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontFamily: 'Afacad Flux',
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastMessage != null || lastMessageTime != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lastMessageSender != null)
                          Text(
                            'From: $lastMessageSender',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSecondary
                                    .withOpacity(0.6)),
                          ),
                        Text(
                          lastMessage ?? '',
                          style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondary
                                  .withOpacity(0.6)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimestamp(lastMessageTime),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondary
                          .withOpacity(0.6),
                    ),
                  ),
                ],
              ),
          ],
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
