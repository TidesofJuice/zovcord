import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/auth_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'provider.dart';
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Zovcord',
          theme: themeProvider.currentTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => AuthScreen(),
            '/chat': (context) => const ChatScreen(),
            '/profile': (context) => ProfileScreen(),
          },
        );
      },
    );
  }
}
