import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatelessWidget {
  final String userId;

  const ChatScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();

    void _sendMessage() {
      if (_messageController.text.trim().isEmpty) return;

      FirebaseFirestore.instance
          .collection('chats')
          .doc(userId) // Используем userId для идентификации чата
          .collection('messages')
          .add({
        'email': FirebaseAuth.instance.currentUser!.email,
        'content': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Чат с $userId'),
        actions: [
          IconButton(
              onPressed: () {
                GoRouter.of(context).go('/chat');
              },
              icon: const Icon(Icons.chat))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(userId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true, // Последние сообщения внизу
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ListTile(
                      title: Text(message['content']),
                      subtitle: Text('Отправлено: ${message['email']}'),
                    );
                  },
                );
              },
            ),
          ),
          // Поле ввода сообщения
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
