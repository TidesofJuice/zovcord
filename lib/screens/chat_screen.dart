import 'package:flutter/material.dart';
import 'package:zovcord/core/model/user_model.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:zovcord/core/widgets/chat_screen_widget.dart' as chat_widgets;
import 'package:get_it/get_it.dart';
import 'package:zovcord/core/logic/chat_controller.dart';
import 'package:go_router/go_router.dart';

// Инициализация глобального локатора зависимостей
final GetIt locator = GetIt.instance;

// Получение сервисов аутентификации и репозитория чатов через локатор
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
    // Инициализация контроллера чата
    chatController = ChatController(controller, scrollController);
    // Загрузка информации о получателе
    receiver = chatRepository.getUserById(widget.receiverId);
    // Проверка статуса пользователя
    _loadUserStatus();
  }

  // Загрузка статуса пользователя (в сети или нет)
  Future<void> _loadUserStatus() async {
    isOnline = await chatRepository.getUserStatus(widget.receiverId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Заголовок AppBar с использованием FutureBuilder для отображения данных о получателе
        title: FutureBuilder<UserModel>(
          future: receiver,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Отображение, пока данные загружаются
              return const Text('Загрузка...');
            } else if (snapshot.hasError) {
              // Сообщение об ошибке, если данные не удалось загрузить
              return const Text('Ошибка');
            } else {
              // Отображение никнейма или email, если данные успешно загружены
              final displayName = snapshot.data?.nickname?.isNotEmpty == true
                  ? snapshot.data?.nickname
                  : widget.receiverEmail;
              return Text(displayName ?? 'No Name');
            }
          },
        ),
        // Кнопка назад
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/chatlist'); // Переход к списку чатов
          },
        ),
        actions: [
          SizedBox(width: 10),
          // Отображение статуса пользователя (Online/Offline)
          Text(
            isOnline ? "Online" : "Offline",
            style: TextStyle(
                fontSize: 16, color: isOnline ? Colors.green : Colors.red),
          ),
        ],
      ),
      body: Center(
        child: Container(
          // Основной контейнер для отображения чата
          decoration: ShapeDecoration(
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          width: 1000,
          height: 600,
          child: Column(
            children: [
              // Список сообщений
              Expanded(
                child: chat_widgets.MessageList(
                  receiverID: widget.receiverId,
                  controller: scrollController,
                ),
              ),
              // Поле ввода сообщения с клавиатурным обработчиком
              KeyboardListener(
                focusNode: FocusNode(),
                autofocus: false,
                onKeyEvent: (event) =>
                    chatController.onKey(event, widget.receiverId),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    // Поле ввода текста
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                            hintText: "Введите сообщение"),
                      ),
                    ),
                    // Кнопка отправки сообщения
                    IconButton(
                      onPressed: () =>
                          chatController.sendMessage(widget.receiverId),
                      icon: const Icon(Icons.send),
                    ),
                    // Кнопка отображения панели эмодзи
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
              // Панель эмодзи, скрывается, если emojiShowing == false
              Offstage(
                offstage: !chatController.emojiShowing,
                child: SizedBox(
                  height: 250,
                  child: EmojiPicker(
                    // Выбор эмодзи
                    onEmojiSelected: (category, emoji) {
                      chatController.onEmojiSelected(emoji);
                    },
                    // Обработка нажатия клавиши удаления
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
