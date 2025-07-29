import 'package:chat_engine/features/authentication/login/login_page.dart';
import 'package:chat_engine/features/authentication/signup_page/signup_page.dart';
import 'package:chat_engine/features/personalization/home_page/home_page.dart';
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
    }

    // Step 4: Navigate to home screen
    Get.offAll(HomePage());
  }

  Future<void> signOutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      await googleSignIn.disconnect();
      await googleSignIn.signOut();
      print('User signed out');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  String? getUserPhotoUrl() {
    return FirebaseAuth.instance.currentUser?.photoURL;
  }

  void goToLoginPage() {
    Get.to(LoginPage());
  }

  void goToSigunUpPage() {
    Get.to(SignupPage());
  }

  void goTochatPage (){
    Get.to(ChatPage());
  }
}