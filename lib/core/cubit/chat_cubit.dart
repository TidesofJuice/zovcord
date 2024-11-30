import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zovcord/core/model/message_model.dart';
import 'package:zovcord/core/cubit/chat_state_cubit.dart';

class ChatCubit extends Cubit<ChatState> {
  final String chatId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ChatCubit({required this.chatId}) : super(ChatState());

  // Метод для загрузки сообщений из Firestore
  Future<void> loadMessages() async {
    emit(state.copyWith(isLoading: true));

    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();

      final messages = snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();

      emit(state.copyWith(messages: messages, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }

  // Метод для отправки сообщения
  Future<void> sendMessage(String senderId, String content, String type) async {
    if (content.trim().isEmpty) return;

    emit(state.copyWith(isLoading: true));

    try {
      final newMessage = MessageModel(
        senderId: senderId,
        content: content.trim(),
        timestamp: DateTime.now(),
        type: type,
      );

      await _firestore.collection('chats').doc(chatId).collection('messages').add(newMessage.toMap());

      // После отправки сообщения загружаем обновленный список сообщений
      loadMessages();
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}