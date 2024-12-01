import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите диалог'),
        actions: [
          IconButton(onPressed: () {GoRouter.of(context).go('/profile');}, icon: const Icon(Icons.people))
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Нет доступных пользователей'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userId = user.id; // ID документа в Firestore
              final userEmail = user['email'] ?? 'Нет email';

              return ListTile(
                leading: const Icon(Icons.person),
                title: Text(userEmail), // Показываем email
                onTap: () {
                  GoRouter.of(context).go(
                    '/chat/$userId', // Передаем userId
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}