import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
        // Настройка панели приложения с заголовком и кнопкой перехода в настройки
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
              context.go('/settings'); // Переход к экрану настроек
            },
          ),
        ],
      ),
      body: Container(
        // Основное содержимое экрана, отображает список пользователей
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
        // Настройка контейнера для списка пользователей
        decoration: ShapeDecoration(
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        width: 1000,
        height: 700,
        child: StreamBuilder<List<UserModel>>(
          // Подключение к потоку данных пользователей с последними сообщениями
          stream: _chatRepository.getUserStreamWithLastMessage(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Отображение индикатора загрузки, если данные еще не пришли
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              // Обработка ошибок при загрузке данных
              print('Ошибка: ${snapshot.error}');
              return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
            }

            final users = snapshot.data ?? []; // Получение списка пользователей

            if (users.isEmpty) {
              // Сообщение о том, что пользователи отсутствуют
              return const Center(child: Text('Нет доступных пользователей'));
            }

            return ListView.builder(
              // Построение списка пользователей
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return UserTile(
                  // Отображение данных отдельного пользователя
                  email: user.email,
                  userId: user.id,
                  isOnline: user.isOnline,
                  nickname: user.nickname,
                  lastMessage: user.lastMessage,
                  lastMessageTime: user.lastMessageTime,
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
    // Форматирование метки времени в строку
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
    final currentUser = _authServices.getCurrentUser(); // Текущий пользователь
    final displayName = nickname?.isNotEmpty == true ? nickname! : email;

    if (currentUser != null && email != currentUser.email) {
      return ListTile(
        // Элемент списка для отдельного пользователя
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(24)),
        hoverColor: Theme.of(context).colorScheme.tertiary,
        textColor: Theme.of(context).colorScheme.onSecondary,
        leading: IconTheme(
          data: Theme.of(context).iconTheme,
          child: const Icon(Icons.person), // Иконка пользователя
        ),
        title: Text(displayName), // Имя пользователя
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOnline ? "Online" : "Offline", // Статус онлайн/офлайн
              style: TextStyle(color: isOnline ? Colors.green : Colors.red),
            ),
            if (lastMessage != null || lastMessageTime != null)
              Row(
                // Отображение последнего сообщения и времени его отправки
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lastMessageSender != null)
                          Text(
                            'From: $lastMessageSender', // Отправитель сообщения
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        Text(
                          lastMessage ?? '', // Последнее сообщение
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTimestamp(
                        lastMessageTime), // Время последнего сообщения
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
          // Действие при нажатии на пользователя
          final encodedEmail = Uri.encodeComponent(email);
          context.go('/chat-with/$encodedEmail/$userId');
        },
      );
    }
    return const SizedBox
        .shrink(); // Пустое место, если пользователь совпадает с текущим
  }
}
