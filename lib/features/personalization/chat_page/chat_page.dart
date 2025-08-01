import 'package:chat_engine/common/widgets/chat_page/chat_input_bar.dart';
import 'package:chat_engine/utils/controller/app_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'message_bubble.dart';
import 'seen_label.dart';
import 'timestamp_label.dart';
import 'user_avatar_with_name.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  const ChatPage({Key? key, required this.receiverId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final appController = Get.find<AppController>();
  final ScrollController _scrollController = ScrollController();
  late String chatId;
  DocumentSnapshot? receiverData;

  @override
  void initState() {
    super.initState();
    final senderId = FirebaseAuth.instance.currentUser!.uid;

    chatId = appController.getChatId(senderId, widget.receiverId);
    FirebaseFirestore.instance.collection('users').doc(widget.receiverId).get().then((doc) {
      if (doc.exists) {
        setState(() {
          receiverData = doc;
        });
      }
    });
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get()
        .then((snapshot) {
      for (var doc in snapshot.docs) {
        doc.reference.update({'isRead': true});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final receiverName = receiverData?.get('name') ?? 'Loading...';
    final photoUrl = receiverData?.get('photoUrl');
    final lastSeen = receiverData?.get('lastSeen');


    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: UserAvatarWithName(
          name: receiverName,
          photoUrl: photoUrl,
          lastSeen: lastSeen,
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone, color: Colors.white, size: 21),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.video, color: Colors.white, size: 21),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;
                final currentUserId = FirebaseAuth.instance.currentUser!.uid;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final data = msg.data() as Map<String, dynamic>;

                    // 👇 Skip message if 'type' or 'content' is missing or null
                    if (data['type'] == null || data['content'] == null) {
                      return const SizedBox.shrink(); // skip this item
                    }

                    final timestamp = data['timestamp'] as Timestamp?;
                    final isMe = data['senderId'] == currentUserId;
                    final isLastMessage = index == messages.length - 1 && isMe;

                    final senderImageUrl = !isMe ? (receiverData?.get('photoUrl') ?? '') : '';

                    return Column(
                      crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if ((index + 1) % 7 == 0 && timestamp != null)
                          TimestampLabel(timestamp: timestamp),
                        MessageBubble(
                          message: data,
                          isMe: isMe,
                          senderImageUrl: senderImageUrl,
                        ),
                        SeenLabel(
                          isLastMessage: isLastMessage,
                          isRead: data['isRead'] ?? false,
                        ),
                      ],
                    );
                  },


                );
              },
            ),
          ),
          ChatInputBar(receiverId: widget.receiverId),
        ],
      ),
    );
  }
}
