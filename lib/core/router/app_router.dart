import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/screens/chat_list_screen.dart';
import 'package:zovcord/screens/login_screen.dart';
import 'package:zovcord/screens/register_screen.dart';
import 'package:zovcord/screens/settings_screen.dart';
import 'package:zovcord/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoRouter router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/chat-list',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/chat/:receiverEmail/:receiverId',
      builder: (BuildContext context, GoRouterState state) {
        return ChatScreen(
          receiverEmail: state.pathParameters['receiverEmail']!,
          receiverId: state.pathParameters['receiverId']!,
        );
      },
    ),
  ],
  redirect: (context, state) {
    // Проверка авторизации
    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    final isGoingToLogin = state.uri.toString() == '/login';

    if (!isAuthenticated && !isGoingToLogin) {
      return '/login';
    }
    return null;
  },
);