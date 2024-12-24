import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/model/user_model.dart';

// Получение экземпляров сервисов через Service Locator
final AuthServices authService = locator.get();
final ChatRepository chatRepository = locator.get();

// Виджет для отображения списка сообщений
class MessageList extends StatelessWidget {
  const MessageList({
    Key? key,
    required this.receiverID,
    required this.controller,
  }) : super(key: key);

  final String receiverID;
  final ScrollController controller;

  @override
  Widget build(BuildContext context) {
    // Получение ID текущего пользователя
    String senderID = authService.getCurrentUser()!.uid;

    // Создание потока данных сообщений
    return StreamBuilder<QuerySnapshot>(
      stream: chatRepository.getChatHistory(_getChatId(senderID, receiverID)),
      builder: (context, snapshot) {
        // Обработка ошибок и состояния загрузки
        if (snapshot.hasError) {
          return const Center(child: Text("Ошибка загрузки сообщений"));
        }
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("ЗАГРУЗКА..."));
        }

        // Отображение списка сообщений
        return ListView(
          controller: controller,
          children: snapshot.data!.docs
              .map((doc) => MessageItem(
                    doc: doc,
                    previousTimestamp: null,
                  ))
              .toList(),
        );
      },
    );
  }

  // Генерация ID чата из ID отправителя и получателя
  String _getChatId(String senderID, String receiverID) {
    final ids = [senderID, receiverID]..sort();
    return ids.join('_');
  }
}

// Виджет для отображения отдельного сообщения
class MessageItem extends StatelessWidget {
  const MessageItem({
    Key? key,
    required this.doc,
    required this.previousTimestamp,
  }) : super(key: key);

  final DocumentSnapshot doc;
  final Timestamp? previousTimestamp;

  @override
  Widget build(BuildContext context) {
    // Получение данных сообщения
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == authService.getCurrentUser()!.uid;

    // Форматирование времени отправки
    String formattedTimestamp = _formatTimestamp(data['timestamp']);

    // Проверка необходимости отображения заголовка с датой
    bool showDateHeader = previousTimestamp == null ||
        !_isSameDay(data['timestamp'], previousTimestamp!);

    // Построение UI сообщения
    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (showDateHeader) _buildDateHeader(context, data['timestamp']),
        Align(
          alignment:
              isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Отображение никнейма отправителя
                FutureBuilder<UserModel>(
                  future: chatRepository.getUserById(data['senderId']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Загрузка...');
                    } else if (snapshot.hasError) {
                      return const Text('Ошибка');
                    } else {
                      return Text(
                        snapshot.data!.nickname ?? 'Unknown',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      );
                    }
                  },
                ),
                // Текст сообщения
                Text(
                  data["message"],
                  style: TextStyle(fontSize: 16),
                ),
                // Время отправки
                Text(
                  formattedTimestamp,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Форматирование timestamp в строку времени
  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('HH:mm').format(date);
  }

  // Проверка, относятся ли сообщения к одному дню
  bool _isSameDay(Timestamp timestamp1, Timestamp timestamp2) {
    final date1 = timestamp1.toDate();
    final date2 = timestamp2.toDate();
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Создание заголовка с датой
  Widget _buildDateHeader(BuildContext context, Timestamp timestamp) {
    final date = timestamp.toDate();
    final formattedDate = DateFormat('dd.MM.yyyy').format(date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        formattedDate,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSecondary,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
