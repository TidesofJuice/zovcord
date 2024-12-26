import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// Модель данных пользователя
class UserModel {
  final String id; // Уникальный идентификатор пользователя
  final String email; // Email пользователя
  final String? nickname; // Имя пользователя (опционально)
  final bool isDarkTheme; // Настройка темы (темная/светлая)
  final bool isOnline; // Статус пользователя (онлайн/оффлайн)
  final int theme; // Тема приложения
  String? lastMessage; // Последнее сообщение
  Timestamp? lastMessageTime; // Время последнего сообщения

  // Конструктор для инициализации объекта UserModel
  UserModel({
    required this.id,
    required this.email,
    this.nickname,
    required this.isDarkTheme,
    required this.isOnline,
    required this.theme,
    this.lastMessage,
    this.lastMessageTime,
  });

  // Метод для преобразования объекта в Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'nickname': nickname,
      'isDarkTheme': isDarkTheme,
      'isOnline': isOnline,
      'theme': theme,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
    };
  }

  // Фабричный метод для создания объекта из Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      nickname: map['nickname'],
      isDarkTheme: map['isDarkTheme'] ?? false,
      isOnline: map['isOnline'] ?? false,
      theme: map['theme'] ?? 1,
      lastMessage: map['lastMessage'],
      lastMessageTime: map['lastMessageTime'],
    );
  }

  // Метод для преобразования объекта в JSON
  String toJson() => json.encode(toMap());

  // Фабричный метод для создания объекта из JSON
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
