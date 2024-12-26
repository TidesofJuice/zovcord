// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

// Класс ChatModel представляет модель данных для чата.
class ChatModel {
  final String chatid; // Уникальный идентификатор чата.
  final List<String> members; // Список участников чата.
  final String? lastMessage; // Последнее сообщение в чате (может быть null).
  final Timestamp timestamp; // Временная метка последнего сообщения.

  // Конструктор класса ChatModel с обязательными параметрами.
  const ChatModel({
    required this.chatid,
    required this.members,
    this.lastMessage,
    required this.timestamp,
  });

  // Метод для создания копии объекта ChatModel с возможностью изменения некоторых полей.
  ChatModel copyWith({
    String? chatid,
    List<String>? members,
    String? lastMessage,
    Timestamp? timestamp,
  }) {
    return ChatModel(
      chatid: chatid ?? this.chatid,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Метод для преобразования объекта ChatModel в Map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatid': chatid,
      'members': members,
      'lastMessage': lastMessage,
      'timestamp': timestamp
          .toDate()
          .toIso8601String(), // Преобразуем Timestamp в строку.
    };
  }

  // Фабричный метод для создания объекта ChatModel из Map.
  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatid: map['chatid'] as String,
      members: List<String>.from(map['members'] as List),
      lastMessage:
          map['lastMessage'] != null ? map['lastMessage'] as String : null,
      timestamp: (map['timestamp'] as Timestamp),
    );
  }

  // Метод для преобразования объекта ChatModel в JSON-строку.
  String toJson() => json.encode(toMap());

  // Фабричный метод для создания объекта ChatModel из JSON-строки.
  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  // Переопределение метода toString для удобного вывода информации о чате.
  @override
  String toString() {
    return 'ChatModel(chatid: $chatid, members: $members, lastMessage: $lastMessage, timestamp: $timestamp)';
  }

  // Переопределение оператора равенства для сравнения объектов ChatModel.
  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;

    return other.chatid == chatid &&
        listEquals(other.members, members) &&
        other.lastMessage == lastMessage &&
        other.timestamp == timestamp;
  }

  // Переопределение метода hashCode для корректного сравнения объектов.
  @override
  int get hashCode {
    return chatid.hashCode ^
        members.hashCode ^
        lastMessage.hashCode ^
        timestamp.hashCode;
  }
}
