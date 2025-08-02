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
  FirebaseAuth get auth => FirebaseAuth.instance;
  GoogleSignInAccount? _user;
  GoogleSignInAccount get user => _user!;

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

  Future<void> signOutUser() async {
    try {
      final userId = auth.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'isOnline': false,
          'lastSeen': FieldValue.serverTimestamp(),
        });
      }

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

  String? getUserPhotoUrl() {
    return auth.currentUser?.photoURL;
  }

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

  Future<void> sendMessage({
    required String receiverId,
    required String messageText,
    String type = 'text',
    Map<String, dynamic>? replyTo, // ✅ optional reply object
  }) async {
    final senderId = FirebaseAuth.instance.currentUser!.uid;
    final chatId = getChatId(senderId, receiverId);
    final timestamp = FieldValue.serverTimestamp();
    final photoUrl = FirebaseAuth.instance.currentUser?.photoURL ?? '';

    final message = {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': messageText,
      'timestamp': timestamp,
      'photoUrl': photoUrl,
      'type': type,
      'isRead': false,
      if (replyTo != null)
        'repliedTo': {
          'senderId': replyTo['senderId'] ?? '',
          'content': replyTo['content'] ?? '',
          'senderName': replyTo['senderName'] ?? '', // ✅ Add this lines
          'type': replyTo['type'] ?? 'text',
        },
    };

    final messageRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    await messageRef.set(message);

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'senderId': senderId,
      'receiverId': receiverId,
    }, SetOptions(merge: true));
  }




  String getChatId(String user1, String user2) {
    return user1.hashCode <= user2.hashCode
        ? '$user1\_$user2'
        : '$user2\_$user1';
  }

  Stream<List<Map<String, dynamic>>> getAllUsersStream() {
    final currentUserId = auth.currentUser!.uid;

    return FirebaseFirestore.instance
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  void goToLoginPage() {
    Get.to(LoginPage());
  }

  void goToSigunUpPage() {
    Get.to(SignupPage());
  }

  void goTochatPage(String receiverId) async {
    final currentUserId = auth.currentUser!.uid;
    final chatId = getChatId(currentUserId, receiverId);

    // 🔁 Mark last message as read
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    if (chatDoc.exists) {
      final lastMessage = chatDoc.data()?['lastMessage'];
      if (lastMessage != null &&
          lastMessage['senderId'] == receiverId &&
          lastMessage['isRead'] == false) {
        await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
          'lastMessage': {
            ...lastMessage,
            'isRead': true,
          }
        }, SetOptions(merge: true));
      }
    }

    // 🕒 Save chat opened time
    await FirebaseFirestore.instance.collection('users').doc(currentUserId).update({
      'chatOpenedAt_$chatId': FieldValue.serverTimestamp(),
    });

    Get.to(() => ChatPage(receiverId: receiverId));
  }
}
