import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Создание глобального экземпляра Service Locator
var locator = GetIt.instance;

// Функция инициализации Service Locator и регистрации зависимостей
Future<void> initServiceLocator() async {
  // Регистрация SharedPreferences как синглтон
  // Используется для хранения локальных настроек приложения
  locator.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());

  // Регистрация экземпляра FirebaseAuth как синглтон
  // Используется для аутентификации пользователей
  locator.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  // Регистрация экземпляра FirebaseFirestore как синглтон
  // Используется для работы с базой данных Firebase
  locator.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  // Регистрация сервиса аутентификации как синглтон
  locator.registerSingleton<AuthServices>(AuthServices());

  // Регистрация репозитория чатов как синглтон
  // Передаем зависимости FirebaseFirestore и FirebaseAuth через Get_it
  locator.registerSingleton<ChatRepository>(
      ChatRepository(locator.get(), locator.get()));
}
