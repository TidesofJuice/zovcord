import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zovcord/core/model/message_model.dart';
import 'package:zovcord/core/model/chat_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ChatRepository(this._firestore, this._auth);

  /// Получает список пользователей.
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  /// Создает новый чат, если он еще не существует.
  Future<void> createChatIfNotExists(String fromId, String toId) async {
    final chatId = _getChatId(fromId, toId);
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    if (!chatDoc.exists) {
      await _firestore.collection('chats').doc(chatId).set({
        'users': [fromId, toId],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Отправляет сообщение.
  Future<void> sendMessage(String senderId, String receiverId, String message) async {
    final chatId = _getChatId(senderId, receiverId);
    final messageData = Message(
      senderID: senderId,
      senderEmail: _auth.currentUser!.email!,
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    ).toMap();

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message,
      'lastMessageTime': Timestamp.now(),
    }, SetOptions(merge: true));
  }

  /// Получает список чатов для пользователя.
  Stream<List<ChatModel>> getChatList(String userId) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatModel.fromMap({
          'id': doc.id,
          'members': data['members'],
          'lastMessage': data['lastMessage'],
          'lastMessageTime': data['lastMessageTime']?.toDate(),
        });
      }).toList();
    });
  }

  /// Получает историю чатов.
  Stream<QuerySnapshot<Object?>> getChatHistory(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  /// Генерирует уникальный идентификатор чата на основе идентификаторов участников.
  String _getChatId(String senderID, String receiverID) {
    final ids = [senderID, receiverID]..sort();
    return ids.join('_');
  }
}