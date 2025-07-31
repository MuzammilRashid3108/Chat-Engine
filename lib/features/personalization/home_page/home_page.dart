import 'dart:async';

import 'package:chat_engine/common/widgets/animations/blur_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../utils/controller/app_controller.dart';
import 'chat_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final appController = Get.put(AppController());

  Future<Map<String, dynamic>> _getLastMessage(String receiverId) async {
    final senderId = FirebaseAuth.instance.currentUser?.uid;
    if (senderId == null) return {'text': '', 'isRead': true};

    final chatId = appController.getChatId(senderId, receiverId);
    final chatDoc = await FirebaseFirestore.instance.collection('chats').doc(chatId).get();

    if (chatDoc.exists && chatDoc.data() != null) {
      final data = chatDoc.data()!;
      final lastMsg = data['lastMessage'];
      if (lastMsg != null && lastMsg is Map<String, dynamic>) {
        return {
          'text': lastMsg['text'] ?? '',
          'isRead': lastMsg['isRead'] ?? true,
          'senderId': lastMsg['senderId'] ?? '',
        };
      }
    }

    return {'text': '', 'isRead': true};
  }

  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp == null) return '';
      if (timestamp is Timestamp) {
        final dateTime = timestamp.toDate();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final msgDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

        if (msgDay == today) {
          return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
        } else {
          return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
        }
      }
    } catch (e) {
      print("Timestamp formatting error: $e");
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF10131A);
    const accentBlue = Color(0xFF0084FF);
    const onlineDot = Color(0xFF4BCB1F);

    return Stack(
      children: [
        SnakeLikeFlyingPlane(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            titleSpacing: 0,
            title: const Padding(
              padding: EdgeInsets.only(left: 18.0),
              child: Text(
                'Chat Engine',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  letterSpacing: 0.3,
                  fontFamily: 'Open Sans',
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white70),
                onPressed: () {
                  appController.signOutUser();
                },
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white70),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: CustomScrollView(
            slivers: [
              // Search Bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: SizedBox(
                    height: 45,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.06),
                        prefixIcon: const Icon(Icons.search, color: Colors.white38),
                        hintText: 'Search',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                          fontFamily: 'Open Sans',
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: Colors.white38,
                    ),
                  ),
                ),
              ),

              // ✅ Stories
              SliverToBoxAdapter(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final users = snapshot.data!.docs;
                    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

                    if (currentUserId == null) {
                      return const Center(
                        child: Text(
                          "No user logged in",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final currentUser = users.any((doc) => doc['uid'] == currentUserId)
                        ? users.firstWhere((doc) => doc['uid'] == currentUserId)
                        : null;

                    final otherUsers = users.where((doc) => doc['uid'] != currentUserId).toList();

                    Widget buildStoryAvatar({
                      required String name,
                      required String photoUrl,
                      bool isCurrentUser = false,
                    }) {
                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFD62976),
                                  Color(0xFFEEA863),
                                  Color(0xFF9B2282),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: CircleAvatar(
                                radius: 26,
                                backgroundImage: (photoUrl.isNotEmpty)
                                    ? NetworkImage(photoUrl)
                                    : AssetImage(
                                    isCurrentUser
                                        ? 'assets/images/default_profile.png'
                                        : 'assets/images/no_profile.webp')
                                as ImageProvider,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 60,
                            child: Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'Open Sans',
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(top: 25, left: 12),
                      child: SizedBox(
                        height: 95,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: otherUsers.length + 1,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              final currentUserData = currentUser?.data() as Map<String, dynamic>? ?? {};
                              final currentUserPhotoUrl = currentUserData['photoUrl'] ?? '';

                              return buildStoryAvatar(
                                name: 'You',
                                photoUrl: currentUserPhotoUrl,
                                isCurrentUser: true,
                              );
                            }

                            final user = otherUsers[index - 1];
                            final userData = user.data() as Map<String, dynamic>;
                            final name = userData['name'] ?? userData['displayName'] ?? 'User';
                            final photoUrl = userData['photoUrl'] ?? '';

                            return buildStoryAvatar(
                              name: name,
                              photoUrl: photoUrl,
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ✅ Chat List
              const SeenAwareUserList(),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: accentBlue,
            onPressed: () {},
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.edit, color: Colors.white),
          ),
        ),
      ],
    );
  }
}