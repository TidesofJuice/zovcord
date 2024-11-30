import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatDetailScreen extends StatelessWidget {
  final String email;

  const ChatDetailScreen({required this.email, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чат с $email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              GoRouter.of(context).go('/chat');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('ху'),
      ),
    );
  }
}
