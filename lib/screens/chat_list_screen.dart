import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/chat_service.dart';
import 'package:zovcord/core/theme/styles/app_text_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final ChatService _chatService = locator.get();
final AuthServices _authServices = locator.get();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.amber,
        title: Text("Список чатов", style: AppTextStyles.appbar1),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              shadows: [
                Shadow(
                    // bottomLeft
                    offset: Offset(-1, -1),
                    color: Colors.black),
                Shadow(
                    // bottomRight
                    offset: Offset(1, -1),
                    color: Colors.black),
                Shadow(
                    // topRight
                    offset: Offset(1, 1),
                    color: Colors.black),
                Shadow(
                    // topLeft
                    offset: Offset(-1, 1),
                    color: Colors.black),
              ],
            ),
            onPressed: () {
              context.go('/settings');
            },
          ),
        ],
      ),
      body: UserList(),
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
        leading: const Icon(Icons.person),
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
