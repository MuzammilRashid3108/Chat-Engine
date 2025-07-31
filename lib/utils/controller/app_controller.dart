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


    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'lastSeen': FieldValue.serverTimestamp(),
      });
    }

    Get.offAll(HomePage());
  }

  // ──────────────────────────────
  // Sign Out User
  // ──────────────────────────────
  Future<void> signOutUser() async {
    try {
      final userId = auth.currentUser?.uid;

      // Step 1: Update Firestore before sign-out
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

      // Step 2: Sign out from Firebase Auth
      await auth.signOut();

      // Step 3: Sign out from Google, if connected
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.disconnect();
        await googleSignIn.signOut();
      }

      print('✅ User signed out successfully');

      // Step 4: Navigate to Welcome Page
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
        'displayName': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'isOnline': true,
        'lastSeen': FieldValue.serverTimestamp(),
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
    final timestamp = FieldValue.serverTimestamp();

    final message = {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': messageText,
      'timestamp': timestamp,
      'type': 'text',
      'isRead': false,
    };

    // ✅ 1. Add message to subcollection
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message);

    // ✅ 2. Store entire message object as lastMessage
    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'senderId': senderId,
      'receiverId': receiverId,
    }, SetOptions(merge: true));
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
  void goTochatPage(String receiverId) async {
    final currentUserId = auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, receiverId);

    // 🔁 Mark last message as read if it was sent by the receiver
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    if (chatDoc.exists) {
      final lastMessage = chatDoc.data()?['lastMessage'];
      if (lastMessage != null &&
          lastMessage['senderId'] == receiverId &&
          lastMessage['isRead'] == false) {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'lastMessage': {
            'senderId': lastMessage['senderId'],
            'receiverId': lastMessage['receiverId'],
            'text': lastMessage['text'],
            'timestamp': lastMessage['timestamp'],
            'type': lastMessage['type'],
            'isRead': true, // ✅ explicitly override
          }
        }, SetOptions(merge: true));

      }
    }

    Get.to(() => ChatPage(receiverId: receiverId));
  }

}
