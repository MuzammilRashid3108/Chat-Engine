import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../../utils/controller/app_controller.dart';


class SeenAwareUserList extends StatefulWidget {
  const SeenAwareUserList({super.key});

  @override
  State<SeenAwareUserList> createState() => _SeenAwareUserListState();
}

class _SeenAwareUserListState extends State<SeenAwareUserList> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const onlineDot = Color(0xFF4BCB1F);

    final appController = Get.find<AppController>();
    final currentUserId = appController.auth.currentUser?.uid;

    return SliverToBoxAdapter(
      child: StreamBuilder<List<Map<String, dynamic>>>(
        stream: appController.getAllUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No users found",
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          final users = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 12),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(
              color: Color(0xFF2A2D35),
              thickness: 0.6,
              height: 1,
              indent: 70,
              endIndent: 16,
            ),
            itemBuilder: (context, i) {
              final user = users[i];
              if (user['uid'] == currentUserId) return const SizedBox();

              return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(appController.getChatId(currentUserId!, user['uid']))
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data == null) return const SizedBox();

                  final docData = snapshot.data!.data() as Map<String, dynamic>?;
                  final lastMsgData = docData?['lastMessage'] ?? {
                    'text': '',
                    'isRead': true,
                    'senderId': '',
                  };

                  final lastMessage = lastMsgData['text'] ?? '';
                  final isRead = lastMsgData['isRead'] ?? true;
                  final senderId = lastMsgData['senderId'] ?? '';
                  final timestamp = lastMsgData['timestamp'];
                  final shouldGlow = !isRead && senderId == user['uid'];

                  String subtitleText = '';
                  if (lastMessage.isEmpty) {
                    subtitleText = 'No messages yet';
                  } else {
                    if (senderId == currentUserId && isRead && timestamp != null) {
                      final readTime = (timestamp as Timestamp).toDate();
                      final now = DateTime.now();
                      final diff = now.difference(readTime);
                      if (diff.inMinutes < 1) {
                        subtitleText = 'Seen at ${DateFormat('hh:mm a').format(readTime)}';
                      } else {
                        subtitleText = lastMessage;
                      }
                    } else {
                      subtitleText = lastMessage;
                    }
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    horizontalTitleGap: 12,
                    leading: Stack(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundImage: user['photoUrl'] != null && user['photoUrl'].isNotEmpty
                              ? NetworkImage(user['photoUrl'])
                              : const AssetImage('assets/images/no_profile.webp')
                          as ImageProvider,
                        ),
                        if (user['isOnline'] == true)
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 13,
                              height: 13,
                              decoration: BoxDecoration(
                                color: onlineDot,
                                shape: BoxShape.circle,
                                border: Border.all(color: Color(0xFF1A1D25), width: 1),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            user['name'] ?? user['displayName'] ?? 'No Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              fontFamily: 'Open Sans',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timestamp != null
                              ? DateFormat('MMM d, hh:mm a')
                              .format((timestamp as Timestamp).toDate())
                              : '',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      subtitleText,
                      style: TextStyle(
                        color: subtitleText == 'No messages yet'
                            ? Colors.white38
                            : (shouldGlow ? Colors.white : Colors.white70),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: shouldGlow
                            ? [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.cyanAccent.withOpacity(0.7),
                            offset: const Offset(0, 0),
                          ),
                        ]
                            : [],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    onTap: () => appController.goTochatPage(user['uid']),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
