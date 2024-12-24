import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:flutter/services.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/locator_service.dart';

// Инициализация глобальных сервисов через Service Locator
final AuthServices authService = locator.get();
final ChatRepository chatRepository = locator.get();

// Основной класс контроллера чата
class ChatController {
  // Контроллеры для управления текстовым полем и прокруткой
  final TextEditingController controller;
  final ScrollController scrollController;

  ChatController(this.controller, this.scrollController);

  // Управление состоянием отображения панели эмодзи
  bool _emojiShowing = false;
  bool get emojiShowing => _emojiShowing;

  // Метод для переключения видимости панели эмодзи
  void toggleEmojiShowing() {
    _emojiShowing = !_emojiShowing;
  }

  // Метод для прокрутки чата вниз к последнему сообщению
  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // Метод отправки сообщения
  Future<void> sendMessage(String receiverId) async {
    if (controller.text.isNotEmpty) {
      try {
        await chatRepository.sendMessage(
          authService.getCurrentUser()!.uid, // Отправитель
          receiverId, // Получатель
          controller.text, // Сообщение
        );
        controller.clear();
        scrollDown();
      } catch (e) {
        throw Exception('Ошибка отправки сообщения: $e');
      }
    }
  }

  // Обработчик выбора эмодзи
  void onEmojiSelected(Emoji emoji) {
    controller.text += emoji.emoji;
  }

  // Обработчик удаления последнего символа при нажатии backspace
  void onBackspacePressed() {
    controller.text = controller.text.characters.skipLast(1).toString();
  }

  // Обработчик нажатия клавиши Enter для отправки сообщения
  void onKey(KeyEvent event, String receiverId) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      sendMessage(receiverId);
    }
  }
}
