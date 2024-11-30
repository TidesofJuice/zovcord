import 'package:flutter/material.dart';
<<<<<<< Updated upstream
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
>>>>>>> Stashed changes

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чаты'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
<<<<<<< Updated upstream
            onPressed: () => Navigator.pushNamed(context, '/profile'),
=======
            onPressed: () {
              GoRouter.of(context).go('/profile');
            },
>>>>>>> Stashed changes
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final email = user['email'] ?? 'Нет почты';

              return ListTile(
                title: Text(email),
                onTap: () {
                  GoRouter.of(context).go('/chat/$email');
                },
              );
            },
          );
        },
      ),
    );
  }
}
