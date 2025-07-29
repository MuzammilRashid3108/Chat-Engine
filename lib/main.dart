import 'package:chat_engine/utils/theme/theme.dart';
import 'package:chat_engine/features/authentication/welcome_page/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/personalization/home_page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ChatEngine());
}

class ChatEngine extends StatelessWidget {
  const ChatEngine({super.key});

  @override
  Widget build(BuildContext context) {
    // 👇 Check if the user is already logged in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      home: currentUser != null ?  HomePage() :  WelcomePage(),
    );
  }
}
