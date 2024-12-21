import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:zovcord/core/repository/chat_repository.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

var locator = GetIt.instance;

Future<void> initServiceLocator() async {
  locator.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());

  locator.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  locator.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  locator.registerSingleton<AuthServices>(
      AuthServices(locator.get(), locator.get()));

  locator.registerSingleton<ChatRepository>(
      ChatRepository(locator.get(), locator.get()));
}
