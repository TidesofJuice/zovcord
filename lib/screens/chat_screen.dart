import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/chat_service.dart';

final ChatService chatServices = locator.get();
final AuthServices authService = locator.get();

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.receiverEmail,
    required this.receiverId,
  }) : super(key: key);

  final String receiverEmail;
  final String receiverId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  bool emojiShowing = false;
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    _loadUserStatus();
  }

  Future<void> _loadUserStatus() async {
    isOnline = await getUserStatus(widget.receiverId);
    setState(() {});
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void sendMessage() async {
    if (controller.text.isNotEmpty) {
      await chatServices.sendMessage(widget.receiverId, controller.text);
      controller.clear();
      scrollDown();
    }
  }

  void onEmojiSelected(Emoji emoji) {
    controller.text += emoji.emoji;
  }

  void onBackspacePressed() {
    controller.text = controller.text.characters.skipLast(1).toString();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      sendMessage();
    }
  }

  Future<bool> getUserStatus(String userId) async {
    final doc =
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['is_online'] ?? false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverEmail,
        ),
        actions: [
          SizedBox(width: 10),
          Text(
            isOnline ? "Online" : "Offline",
            style: TextStyle(
                fontSize: 16, color: isOnline ? Colors.green : Colors.red),
          ),
        ],
      ),
      body: Center(
        child: Container(
          decoration: ShapeDecoration(
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          width: 1000,
          height: 600,
          child: Column(
            children: [
              Expanded(
                child: MessageList(
                  receiverID: widget.receiverId,
                  controller: scrollController,
                ),
              ),
              KeyboardListener(
                focusNode: FocusNode(),
                autofocus: false,
                onKeyEvent: _handleKeyEvent,
                child: Row(
                  children: [
                    SizedBox(width: 10,),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            hintText: "Введите сообщение"),
                      ),
                    ),
                    IconButton(
                      onPressed: sendMessage,
                      icon: const Icon(Icons.send),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          emojiShowing = !emojiShowing;
                        });
                      },
                      icon: const Icon(Icons.emoji_emotions),
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: !emojiShowing,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      onEmojiSelected(emoji);
                    },
                    onBackspacePressed: onBackspacePressed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return StreamBuilder(
      stream: chatServices.getMessage(receiverID, senderID),
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
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
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
