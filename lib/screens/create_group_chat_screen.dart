import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:zovcord/core/model/user_model.dart';

final ChatRepository chatRepository = locator.get();

class CreateGroupChatScreen extends StatefulWidget {
  const CreateGroupChatScreen({super.key});

  @override
  State<CreateGroupChatScreen> createState() => _CreateGroupChatScreenState();
}

class _CreateGroupChatScreenState extends State<CreateGroupChatScreen> {
  final TextEditingController _chatNameController = TextEditingController();
  final List<UserModel> _selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать групповой чат'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _chatNameController,
              decoration: const InputDecoration(
                labelText: 'Название чата',
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<UserModel>>(
              stream: chatRepository.getUserStreamWithLastMessage(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }

                final users = snapshot.data ?? [];

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final isSelected = _selectedUsers.contains(user);

                    return ListTile(
                      title: Text(user.nickname ?? user.email),
                      subtitle: Text(user.email),
                      trailing: isSelected
                          ? const Icon(Icons.check_box)
                          : const Icon(Icons.check_box_outline_blank),
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedUsers.remove(user);
                          } else {
                            _selectedUsers.add(user);
                          }
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _selectedUsers.length >= 2
                  ? () async {
                      final chatName = _chatNameController.text.trim();
                      if (chatName.isNotEmpty) {
                        await chatRepository.createGroupChat(
                          chatName,
                          _selectedUsers,
                        );
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Введите название чата'),
                          ),
                        );
                      }
                    }
                  : null,
              child: const Text('Создать чат'),
            ),
          ),
        ],
      ),
    );
  }
}