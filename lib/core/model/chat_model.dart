import 'dart:convert';

class ChatModel {
  final String id;
  final List<String> members;
  final String? lastMessage;
  final DateTime? lastMessageTime;

  const ChatModel({
    required this.id,
    required this.members,
    this.lastMessage,
    this.lastMessageTime,
  });

  ChatModel copyWith({
    String? id,
    List<String>? members,
    String? lastMessage,
    DateTime? lastMessageTime,
  }) {
    return ChatModel(
      id: id ?? this.id,
      members: members ?? this.members,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'members': members,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime?.millisecondsSinceEpoch,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      members: List<String>.from(map['members'] as List<dynamic>),
      lastMessage: map['lastMessage'] as String?,
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) =>
      ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatModel(id: $id, members: $members, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatModel &&
        other.id == id &&
        other.members == members &&
        other.lastMessage == lastMessage &&
        other.lastMessageTime == lastMessageTime;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        members.hashCode ^
        lastMessage.hashCode ^
        lastMessageTime.hashCode;
  }
}