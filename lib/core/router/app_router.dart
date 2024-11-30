import 'package:go_router/go_router.dart';
import 'package:zovcord/screens/chat_list_screen.dart';
import 'package:zovcord/screens/chat_screen.dart';
import 'package:zovcord/screens/login_screen.dart';
import 'package:zovcord/screens/profile_screen.dart';
import 'package:zovcord/screens/register_screen.dart';
import 'package:zovcord/screens/splash_screen.dart';

abstract class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/chat/:userId', // Динамический параметр
        builder: (context, state) {
          // Получаем параметр userId
          final userId = state.pathParameters['userId'] ?? ''; // Используем pathParameters
          return ChatScreen(userId: userId); // Передаем userId в ChatScreen
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/list',
        builder: (context, state) => const ChatListScreen(),
      ),
    ],
  );
}