import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';

final AuthServices authService = locator.get();
final ChatRepository chatRepository = locator.get();

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
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder<QuerySnapshot>(
      stream: chatRepository.getChatHistory(_getChatId(senderID, receiverID)),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text("Ошибка загрузки сообщений"));
        }
        if (!snapshot.hasData ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("ЗАГРУЗКА..."));
        }
        return ListView(
          controller: controller,
          children: snapshot.data!.docs
              .map((doc) => MessageItem(doc: doc))
              .toList(),
        );
      },
    );
  }

  String _getChatId(String senderID, String receiverID) {
    final ids = [senderID, receiverID]..sort();
    return ids.join('_');
  }
}

class MessageItem extends StatelessWidget {
  const MessageItem({
    Key? key,
    required this.doc,
  }) : super(key: key);

  final DocumentSnapshot doc;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderId'] == authService.getCurrentUser()!.uid;
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment:
              isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              data['senderEmail'],
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              data["message"],
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}