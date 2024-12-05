import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zovcord/screens/chat_list_screen.dart';
import 'package:zovcord/screens/login_screen.dart';
import 'package:zovcord/screens/register_screen.dart';
import 'package:zovcord/screens/profile_screen.dart';
import 'package:zovcord/screens/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return const HomeScreen();
              } else {
                return LoginScreen(callBack: () => context.go('/register'));
              }
            } else {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
          },
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: 'login',
          builder: (BuildContext context, GoRouterState state) {
            return LoginScreen(callBack: () => context.go('/register'));
          },
        ),
        GoRoute(
          path: 'register',
          builder: (BuildContext context, GoRouterState state) {
            return RegisterScreen(callBack: () => context.go('/login'));
          },
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) {
            return const SettingsScreen();
          },
        ),
        GoRoute(
          path: 'chat/:receiverEmail/:receiverId',
          builder: (BuildContext context, GoRouterState state) {
            return ChatScreen(
              receiverEmail: state.pathParameters['receiverEmail']!,
              receiverId: state.pathParameters['receiverId']!,
            );
          },
        ),
      ],
    ),
  ],
);
