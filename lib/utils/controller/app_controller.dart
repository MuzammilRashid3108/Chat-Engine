import 'package:chat_engine/features/authentication/login/login_page.dart';
import 'package:chat_engine/features/authentication/signup_page/signup_page.dart';
import 'package:chat_engine/features/authentication/welcome_page/welcome_page.dart';
import 'package:chat_engine/features/personalization/home_page/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/personalization/chat_page/chat_page.dart';

class AppController extends GetxController {
  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount? _user;

  GoogleSignInAccount get user => _user!;

  Future signInWithGoogle() async {
    // Step 1: Start Google Sign-In flow
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return; // User cancelled login

    _user = googleUser;

    // Step 2: Get Google Auth credentials
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Step 3: Sign in with Firebase
    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      String? photoURL = firebaseUser.photoURL;
      print('User Photo URL: $photoURL');

    }      await saveUserInfo();


    // Step 4: Navigate to home screen
    Get.offAll(HomePage());
  }

  Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect(); // Disconnect and reset Google session
        await googleSignIn.signOut();    // Sign out from Google
      }

      print('✅ User signed out successfully');
      Get.offAll(() => WelcomePage());
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }


  String? getUserPhotoUrl() {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }


  Future<void> saveUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user!.uid);

    final snapshot = await userDoc.get();
    if (!snapshot.exists) {
      await userDoc.set({
        'uid': user.uid,
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'isOnline': true,
      });
    }
  }


  // Chat Logic

  Future<void> sendMessage({
    required String receiverId,
    required String messageText,
  }) async {
    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = getChatId(senderId, receiverId);

    final message = {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);
  }

  // Chat ID Generator
  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '$user1\_$user2'
        : '$user2\_$user1';
  }



  //Nvigtion


  void goToLoginPage() {
    Get.to(LoginPage());
  }

  void goToSigunUpPage() {
    Get.to(SignupPage());
  }

  void goTochatPage(String receiverId) {
    Get.to(() => ChatPage(receiverId: receiverId));
  }

}