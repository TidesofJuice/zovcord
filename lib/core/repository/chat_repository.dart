import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zovcord/core/model/message_model.dart';
import 'package:zovcord/core/model/chat_model.dart';
import 'package:zovcord/core/model/user_model.dart';

// Класс репозитория для управления чатами и сообщениями
class ChatRepository {
  // Инициализация экземпляров Firebase
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Конструктор класса
  ChatRepository(this._firestore, this._auth);

  // Поиск
  Stream<List<UserModel>> searchUsers(String query) {
    if (query.isEmpty) return Stream.value([]);

    return _firestore
        .collection('Users')
        .where('email', isGreaterThanOrEqualTo: query)
        .where('email', isLessThan: query + 'z')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    });
  }

  // Получение потока данных пользователей с их последними сообщениями
  Stream<List<UserModel>> getUserStreamWithLastMessage() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return Stream.value([]);

    // Получение всех пользователей кроме текущего
    return _firestore
        .collection('Users')
        .where('id', isNotEqualTo: currentUserId)
        .snapshots()
        .asyncMap((userSnapshot) async {
      List<UserModel> users = [];

      // Получение всех чатов для текущего пользователя
      final chatSnapshot = await _firestore
          .collection('chats')
          .where('members', arrayContains: currentUserId)
          .get();

      // Создание карты данных чатов, индексированной по ID собеседника
      Map<String, Map<String, dynamic>> chatData = {};
      for (var doc in chatSnapshot.docs) {
        final members = List<String>.from(doc.data()['members']);
        final otherUserId = members.firstWhere((id) => id != currentUserId);
        chatData[otherUserId] = {
          'lastMessage': doc.data()['lastMessage'],
          'lastMessageTime': doc.data()['lastMessageTime'],
        };
      }

      // Обработка информации о каждом пользователе
      for (var doc in userSnapshot.docs) {
        final userId = doc.id;
        final userData = doc.data();
        final userChatData = chatData[userId];

        // Создание объекта пользователя с данными из чата
        users.add(UserModel(
          id: userId,
          email: userData['email'],
          nickname: userData['nickname'] ?? '',
          isDarkTheme: userData['isDarkTheme'] ?? false,
          isOnline: userData['isOnline'] ?? false,
          theme: userData['theme'] ?? 1,
          lastMessage: userChatData?['lastMessage'],
          lastMessageTime: userChatData?['lastMessageTime'],
        ));
      }

      // Сортировка пользователей по времени последнего сообщения
      users.sort((a, b) {
        if (a.lastMessageTime == null && b.lastMessageTime == null) return 0;
        if (a.lastMessageTime == null) return 1;
        if (b.lastMessageTime == null) return -1;
        return b.lastMessageTime!.compareTo(a.lastMessageTime!);
      });

      return users;
    });
  }

  // Методы для работы с пользовательскими данными

  // Обновление никнейма пользователя
  Future<void> updateNickname(String uid, String nickname) async {
    await _firestore.collection('Users').doc(uid).update({
      'nickname': nickname,
    });
  }

  // Получение информации о пользователе по его ID
  Future<UserModel> getUserById(String uid) async {
    final doc = await _firestore.collection('Users').doc(uid).get();
    return UserModel.fromMap(doc.data()!);
  }

  // Получение текущего никнейма пользователя
  Future<String?> getCurrentNickname(String uid) async {
    final doc = await _firestore.collection('Users').doc(uid).get();
    if (doc.exists) {
      return doc.data()?['nickname'];
    }
    return null;
  }

  // Получение статуса онлайн пользователя
  Future<bool> getUserStatus(String userId) async {
    final doc = await _firestore.collection('Users').doc(userId).get();
    if (doc.exists) {
      return doc.data()?['is_online'] ?? false;
    }
    return false;
  }

  // Методы для работы с чатами

  // Создание нового чата, если он не существует
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

  // Отправка сообщения
  Future<void> sendMessage(
      String senderId, String receiverId, String message) async {
    final chatId = _getChatId(senderId, receiverId);
    final messageData = Message(
      senderID: senderId,
      senderEmail: _auth.currentUser!.email!,
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    ).toMap();

    // Создание или обновление документа чата
    await _firestore.collection('chats').doc(chatId).set({
      'members': [senderId, receiverId],
    }, SetOptions(merge: true));

    // Сохранение сообщения в подколлекции
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    // Обновление метаданных чата
    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': message,
      'lastMessageTime': Timestamp.now(),
      'members': [senderId, receiverId],
    }, SetOptions(merge: true));
  }

  // Получение списка чатов пользователя
  Stream<List<ChatModel>> getChatList(String userId) {
    return _firestore
        .collection('chats')
        .where('members', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ChatModel.fromMap({
          'id': doc.id,
          'members': data['members'],
          'lastMessage': data['lastMessage'],
          'lastMessageTime': data['lastMessageTime'],
        });
      }).toList();
    });
  }

  // Получение истории сообщений чата
  Stream<QuerySnapshot<Object?>> getChatHistory(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  // Вспомогательный метод для генерации ID чата
  String _getChatId(String senderID, String receiverID) {
    final ids = [senderID, receiverID]..sort();
    return ids.join('_');
  }
}
