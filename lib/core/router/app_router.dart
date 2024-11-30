import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zovcord/core/cubit/auth_cubit.dart';
import 'package:zovcord/screens/chat_screen.dart';
import 'package:zovcord/screens/login_screen.dart';
import 'package:zovcord/screens/profile_screen.dart';
import 'package:zovcord/screens/register_screen.dart';
import 'package:zovcord/screens/splash_screen.dart';
import 'package:zovcord/screens/chat_detail_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      // Access the current authentication state
      final authCubit = context.read<AuthCubit>();
      final isAuthenticated = authCubit.state.isAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isRegistering = state.uri.toString() == '/register';

      // If not authenticated and not on login/register, redirect to login
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/login';
      }

      // If authenticated and on login/register, redirect to chat
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/chat';
      }

      // Otherwise, allow navigation
      return null;
    },
    routes: [
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
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
        path: '/chat/:email',
        builder: (context, state) {
          final email = state.pathParameters['email']!;
          return ChatDetailScreen(email: email);
        },
      ),
    ],
  );
}