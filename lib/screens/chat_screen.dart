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

  final String receiverEmail; // Email получателя
  final String receiverId; // ID получателя

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final controller =
      TextEditingController(); // Контроллер текстового поля для ввода сообщений
  final ScrollController scrollController =
      ScrollController(); // Контроллер прокрутки для списка сообщений
  late ChatController chatController; // Логика управления чатом
  late Future<UserModel> receiver; // Будущий объект с данными о получателе
  bool emojiShowing = false; // Флаг отображения панели эмодзи
  bool isOnline = false; // Статус "в сети"

  @override
  void initState() {
    super.initState();

    chatController = ChatController(controller, scrollController);

    receiver = chatRepository.getUserById(widget.receiverId);

    loadUserStatus();
  }

  Future<void> loadUserStatus() async {
    isOnline = await chatRepository.getUserStatus(widget.receiverId);
    setState(() {});
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
              final displayName = snapshot.data?.nickname?.isNotEmpty == true
                  ? snapshot.data?.nickname
                  : widget.receiverEmail;
              return Text(displayName ?? 'No Name');
            }
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/chatlist');
          },
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10),
          width: 1000,
          height: double.infinity,
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
                onKeyEvent: (event) =>
                    chatController.onKey(event, widget.receiverId),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            ),
                              hintText: "Введите сообщение"),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          chatController.sendMessage(widget.receiverId),
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
