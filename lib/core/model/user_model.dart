import 'dart:convert';

class UserModel {
  final String id; // Уникальный идентификатор пользователя
  final String email; // Email пользователя
  final String? name; // Имя пользователя (опционально)
  final bool isDarkTheme; // Настройка темы (темная/светлая)

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.isDarkTheme = false, // По умолчанию светлая тема
  });

  // Метод для преобразования объекта в Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'isDarkTheme': isDarkTheme,
    };
  }

  // Фабричный метод для создания объекта из Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] != null ? map['name'] as String : null,
      isDarkTheme: map['isDarkTheme'] ?? false,
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
    String? name,
    bool? isDarkTheme,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, name: $name, isDarkTheme: $isDarkTheme)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.isDarkTheme == isDarkTheme;
  }

  @override
  int get hashCode {
    return id.hashCode ^ email.hashCode ^ name.hashCode ^ isDarkTheme.hashCode;
  }
}