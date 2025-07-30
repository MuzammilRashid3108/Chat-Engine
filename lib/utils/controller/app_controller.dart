import 'package:chat_engine/features/authentication/login/login_page.dart';
import 'package:chat_engine/features/authentication/signup_page/signup_page.dart';
import 'package:chat_engine/features/authentication/welcome_page/welcome_page.dart';
import 'package:chat_engine/features/personalization/home_page/home_page.dart';
import 'package:chat_engine/features/personalization/chat_page/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AppController extends GetxController {
  final googleSignIn = GoogleSignIn();

  /// Getter for FirebaseAuth instance
  FirebaseAuth get auth => FirebaseAuth.instance;

  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

  // ──────────────────────────────
  // Sign In with Google
  // ──────────────────────────────
  Future signInWithGoogle() async {
    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) return;

    _user = googleUser;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential = await auth.signInWithCredential(credential);
    User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      print('User Photo URL: ${firebaseUser.photoURL}');
    }

    await saveUserInfo();
    Get.offAll(HomePage());
  }

  // ──────────────────────────────
  // Sign Out User
  // ──────────────────────────────
  Future<void> signOutUser() async {
    try {
      await auth.signOut();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      print('✅ User signed out successfully');
      Get.offAll(() => WelcomePage());
    } catch (e) {
      print('❌ Error signing out: $e');
    }
  }

  // ──────────────────────────────
  // Get User Photo URL
  // ──────────────────────────────
  String? getUserPhotoUrl() {
    return auth.currentUser?.photoURL;
  }

  // ──────────────────────────────
  // Save User Info to Firestore
  // ──────────────────────────────
  Future<void> saveUserInfo() async {
    final user = auth.currentUser;
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

  // ──────────────────────────────
  // Send Message
  // ──────────────────────────────
  Future<void> sendMessage({
    required String receiverId,
    required String messageText,
  }) async {
    final senderId = auth.currentUser!.uid;
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

  // ──────────────────────────────
  // Generate Chat ID
  // ──────────────────────────────
  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '$user1\_$user2'
        : '$user2\_$user1';
  }

  // ──────────────────────────────
  // Get All Users Stream (Excluding Current User)
  // ──────────────────────────────
  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    final currentUserId = auth.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ──────────────────────────────
  // Navigation - Go to Login Page
  // ──────────────────────────────
  void goToLoginPage() {
    Get.to(LoginPage());
  }

  // ──────────────────────────────
  // Navigation - Go to Signup Page
  // ──────────────────────────────
  void goToSigunUpPage() {
    Get.to(SignupPage());
  }

  // ──────────────────────────────
  // Navigation - Go to Chat Page
  // ──────────────────────────────
  void goTochatPage(String receiverId) {
    Get.to(() => ChatPage(receiverId: receiverId));
  }
}
