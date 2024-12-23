// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserModel {
  final String id; // Уникальный идентификатор пользователя
  final String email; // Email пользователя
  final String? nickname; // Имя пользователя (опционально)
  final bool isDarkTheme; // Настройка темы (темная/светлая)

  UserModel({
    required this.id,
    required this.email,
    this.nickname,
    this.isDarkTheme = false, // По умолчанию светлая тема
  });

  // Метод для преобразования объекта в Map
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'email': email,
      'nickname': nickname,
      'isDarkTheme': isDarkTheme,
    };
  }

  // Фабричный метод для создания объекта из Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      nickname: map['nickname'] != null ? map['nickname'] as String : null,
      isDarkTheme: map['isDarkTheme'] as bool,
    );
  }

  // Метод для преобразования объекта в JSON
  String toJson() => json.encode(toMap());

  // Фабричный метод для создания объекта из JSON
  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  // Метод для создания копии объекта с возможностью изменения полей
  UserModel copyWith({
    String? id,
    String? email,
    String? nickname,
    bool? isDarkTheme,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, nickname: $nickname, isDarkTheme: $isDarkTheme)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.id == id &&
      other.email == email &&
      other.nickname == nickname &&
      other.isDarkTheme == isDarkTheme;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      email.hashCode ^
      nickname.hashCode ^
      isDarkTheme.hashCode;
  }
}
