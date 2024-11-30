import 'dart:convert';

class MessageModel {
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String type;

  MessageModel({
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.type,
  });

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'] as String? ?? '',
      content: map['content'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
      type: map['type'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'type': type,
    };
  }

  String toJson() => json.encode(toMap());
 
  static MessageModel fromJson(String source) =>
      MessageModel.fromMap(json.decode(source));
}