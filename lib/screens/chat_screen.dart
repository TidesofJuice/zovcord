import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => GoRouter.of(context).go('/profile'),
          ),
        ],
      ),
      body: const Stack(
        children: [
          Center(
            child: Text('Текст'),
          ),
        ],
      ),
    );
  }
}
