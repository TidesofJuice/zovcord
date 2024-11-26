import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zovcord/core/cubit/auth_cubit.dart';
import 'package:zovcord/core/router/app_router.dart';
import 'core/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyD2H3LlCIt-6vMIeAaSsdvBzfsIA5PKBpU",
      authDomain: "zovcord-goida.firebaseapp.com",
      projectId: "zovcord-goida",
      storageBucket: "zovcord-goida.appspot.com",
      messagingSenderId: "611390456402",
      appId: "1:611390456402:web:5f1ce6a7ecfe2bff51158b",
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Получаем ThemeProvider из контекста
    final themeProvider = Provider.of<ThemeProvider>(context);

    return BlocProvider(
      create: (_) => AuthCubit(),
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        title: 'Zovcord',
        theme: themeProvider.currentTheme, // Используем текущую тему
      ),
    );
  }
}