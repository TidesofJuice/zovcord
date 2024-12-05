import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:zovcord/core/services/auth_service.dart';
import 'package:zovcord/core/services/chat_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

var locator = GetIt.instance;

Future<void> initSerivceLocator() async {
  locator.registerSingleton<SharedPreferences>(
      await SharedPreferences.getInstance());

  locator.registerSingleton<FirebaseAuth>(FirebaseAuth.instance);

  locator.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  locator.registerSingleton<AuthServices>(
      AuthServices(locator.get(), locator.get()));

  locator.registerSingleton<ChatService>(
      ChatService(locator.get(), locator.get()));
}