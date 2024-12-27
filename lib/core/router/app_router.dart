import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/screens/chat_list_screen.dart';
import 'package:zovcord/screens/login_screen.dart';
import 'package:zovcord/screens/register_screen.dart';
import 'package:zovcord/screens/settings_screen.dart';
import 'package:zovcord/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:zovcord/screens/create_group_chat_screen.dart';

// Создание и настройка маршрутизатора приложения
final GoRouter router = GoRouter(
  // Начальный маршрут - экран логина
  initialLocation: '/login',

  // Определение всех доступных маршрутов
  routes: [
    // Маршрут к списку чатов
    GoRoute(
      path: '/chatlist',
      builder: (context, state) => const ChatListScreen(),
    ),

    // Маршрут к экрану входа
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),

    // Маршрут к экрану регистрации
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),

    // Маршрут к настройкам
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: '/creategroupchat',
      builder: (context, state) => const CreateGroupChatScreen(),
    ),
    // Маршрут к конкретному чату с параметрами email и userId
    GoRoute(
      path: '/chat-with/:email/:userId',
      builder: (BuildContext context, GoRouterState state) {
        // Декодирование параметров из URL
        final email = Uri.decodeComponent(state.pathParameters['email']!);
        final userId = state.pathParameters['userId']!;

        // Возврат экрана чата с нужными параметрами
        return ChatScreen(
          receiverEmail: email,
          receiverId: userId,
        );
      },
    ),
  ],

  // Функция перенаправления для проверки аутентификации
  redirect: (context, state) {
    // Проверка аутентификации пользователя
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    // Проверка, пытается ли пользователь войти
    final isGoingToLogin = state.uri.toString() == '/login';

    // Если пользователь не аутентифицирован и не пытается войти -
    // перенаправляем на регистрацию
    if (!isAuthenticated && !isGoingToLogin) {
      return '/register';
    }
    return null; // В остальных случаях позволяем переход
  },
);
