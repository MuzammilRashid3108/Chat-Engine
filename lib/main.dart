import 'package:chat_engine/utils/theme/theme.dart';
import 'package:chat_engine/features/authentication/welcome_page/welcome_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/personalization/home_page/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ChatEngine());
}

class ChatEngine extends StatefulWidget {
  const ChatEngine({super.key});

  @override
  State<ChatEngine> createState() => _ChatEngineState();
}

class _ChatEngineState extends State<ChatEngine> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  @override
  void initState() {
    super.initState();
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        if (msg == AppLifecycleState.paused.toString() ||
            msg == AppLifecycleState.detached.toString()) {
          // App in background or closed
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'isOnline': false,
            'lastSeen': FieldValue.serverTimestamp(),
          });
        } else if (msg == AppLifecycleState.resumed.toString()) {
          // App came back to foreground
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'isOnline': true,
          });
        }
      }
      return Future.value();
    });
  }

  @override
  Widget build(BuildContext context) {

    // 👇 Check if the user is already logged in
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return GetMaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      home: currentUser != null ?  HomePage() :  WelcomePage(),
    );
  }
}
