import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatModel {
  final String chatId;
  final List<String> members;
  final String? lastMessage;
  final Timestamp createdAt;
  final String name;
  final bool isGroup;

  GroupChatModel({
    required this.chatId,
    required this.members,
    this.lastMessage,
    required this.createdAt,
    required this.name,
    this.isGroup = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'members': members,
      'lastMessage': lastMessage,
      'createdAt': createdAt,
      'name': name,
      'isGroup': isGroup,
    };
  }

  factory GroupChatModel.fromMap(Map<String, dynamic> map) {
    return GroupChatModel(
      chatId: map['chatId'] as String,
      members: List<String>.from(map['members'] as List),
      lastMessage: map['lastMessage'] as String?,
      createdAt: map['createdAt'] as Timestamp,
      name: map['name'] as String,
      isGroup: map['isGroup'] as bool? ?? true,
    );
  }
}