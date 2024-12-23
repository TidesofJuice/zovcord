import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/locator_service.dart';
import 'package:zovcord/core/theme/theme_provider.dart';
import 'package:zovcord/core/router/app_router.dart';
import 'package:zovcord/core/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: firebaseOptions,
  );
  await initServiceLocator();

  final authService = locator.get<AuthServices>();
  FirebaseAuth.instance.authStateChanges().listen((User? user) {
    if (user == null) {
      authService.updateUserStatus(false); // Обновление статуса на оффлайн
    } else {
      authService.updateUserStatus(true); // Обновление статуса на онлайн
    }
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.currentTheme,
      routerConfig: router,
    );
  }
}
