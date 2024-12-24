// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatModel {
  final String chatid;
  final List<String> members;
  final String? lastMessage;
  final Timestamp timestamp;

  const ChatModel({
    required this.chatid,
    required this.members,
    this.lastMessage,
    required this.timestamp,
  });

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'chatid': chatid,
      'members': members,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toDate().toIso8601String(),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      chatid: map['chatid'] as String,
      members: List<String>.from(map['members'] as List),
      lastMessage: map['lastMessage'] != null ? map['lastMessage'] as String : null,
      timestamp: (map['timestamp'] as Timestamp),
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatModel(chatid: $chatid, members: $members, lastMessage: $lastMessage, timestamp: $timestamp)';
  }

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.chatid == chatid &&
      listEquals(other.members, members) &&
      other.lastMessage == lastMessage &&
      other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return chatid.hashCode ^
      members.hashCode ^
      lastMessage.hashCode ^
      timestamp.hashCode;
  }
}
