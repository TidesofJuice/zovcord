import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:flutter/services.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/locator_service.dart';

final AuthServices authService = locator.get();
final ChatRepository chatRepository = locator.get();

class ChatController {
  final TextEditingController controller;
  final ScrollController scrollController;

  ChatController(this.controller, this.scrollController);

  bool _emojiShowing = false;
  bool get emojiShowing => _emojiShowing;

  void toggleEmojiShowing() {
    _emojiShowing = !_emojiShowing;
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

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

  void onEmojiSelected(Emoji emoji) {
    controller.text += emoji.emoji;
  }

  void onBackspacePressed() {
    controller.text = controller.text.characters.skipLast(1).toString();
  }

  void onKey(KeyEvent event, String receiverId) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.enter) {
      sendMessage(receiverId);
    }
  }
}