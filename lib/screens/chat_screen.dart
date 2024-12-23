import 'package:flutter/material.dart';
import 'package:zovcord/core/model/user_model.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:zovcord/core/widgets/chat_screen_widget.dart' as chat_widgets;
import 'package:get_it/get_it.dart';
import 'package:zovcord/core/logic/chat_controller.dart';
import 'package:go_router/go_router.dart';

final GetIt locator = GetIt.instance;

final AuthServices authService = locator.get();
final ChatRepository chatRepository = locator.get();

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
  late ChatController chatController;
  late Future<UserModel> receiver;

  @override
  void initState() {
    super.initState();
    chatController = ChatController(controller, scrollController);
    receiver = chatRepository.getUserById(widget.receiverId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<UserModel>(
          future: receiver,
          builder: (context, snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Загрузка...');
            } else if (snapshot.hasError) {
              return const Text('Ошибка');
            } else {
              return Text(snapshot.data?.nickname ?? 'No Name');
            }
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/chat-list');
          },
        ),
      ),
      body: Center(
        child: Container(
          width: 700,
          height: 600,
          child: Column(
            children: [
              Expanded(
                child: chat_widgets.MessageList(
                  receiverID: widget.receiverId,
                  controller: scrollController,
                ),
              ),
              KeyboardListener(
                focusNode: FocusNode(),
                autofocus: false,
                onKeyEvent: (event) => chatController.onKey(event, widget.receiverId),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            hintText: "Введите сообщение"),
                      ),
                    ),
                    IconButton(
                      onPressed: () => chatController.sendMessage(widget.receiverId),
                      icon: const Icon(Icons.send),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          chatController.toggleEmojiShowing();
                        });
                      },
                      icon: const Icon(Icons.emoji_emotions),
                    ),
                  ],
                ),
              ),
              Offstage(
                offstage: !chatController.emojiShowing,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    onEmojiSelected: (category, emoji) {
                      chatController.onEmojiSelected(emoji);
                    },
                    onBackspacePressed: chatController.onBackspacePressed,
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