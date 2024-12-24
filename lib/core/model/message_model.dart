import 'package:cloud_firestore/cloud_firestore.dart';

// Класс Message представляет собой модель сообщения в чате
class Message {
  // Определение основных полей сообщения
  final String senderID; // ID отправителя
  final String senderEmail; // Email отправителя
  final String receiverId; // ID получателя
  final String message; // Текст сообщения
  final Timestamp timestamp; // Временная метка отправки

  // Конструктор класса с обязательными параметрами
  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  // Метод преобразования объекта Message в Map для сохранения в базу данных
  Map<String, dynamic> toMap() {
    return {
      'senderId': senderID,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }

  // Фабричный конструктор для создания объекта Message из Map
  // Используется при получении данных из базы данных
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderId'] as String,
      senderEmail: map['senderEmail'] as String,
      receiverId: map['receiverId'] as String,
      message: map['message'] as String,
      timestamp: map['timestamp'] as Timestamp,
    );
  }
}
