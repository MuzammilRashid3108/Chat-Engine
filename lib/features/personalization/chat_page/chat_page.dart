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
  Map<String, dynamic>? replyMessage;

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

  void deleteMessageForMe(Map<String, dynamic> message) {
    debugPrint('🗑 Delete for me: ${message['content']}');
  }

  void unsendMessage(Map<String, dynamic> message) {
    debugPrint('❌ Unsend message: ${message['content']}');
  }

  void handleForward(Map<String, dynamic> message) async {
    final selectedUserId = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('users').get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final users = snapshot.data?.docs ?? [];

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index].data() as Map<String, dynamic>;
                  final userId = users[index].id;

                  // Skip current user
                  if (userId == FirebaseAuth.instance.currentUser?.uid) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    onTap: () => Navigator.pop(context, userId),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user['photoUrl'] ?? ''),
                    ),
                    title: Text(user['name'] ?? 'No Name',
                        style: const TextStyle(color: Colors.white)),

                  );
                },
              );
            },
          ),
        );
      },
    );

    if (selectedUserId != null) {
      sendMessage(
        receiverId: selectedUserId,
        type: message['type'],
        content: message['content'],
        forwarded: true,
      );
    }
  }

  void sendMessage({
    required String receiverId,
    required String type,
    required String content,
    bool forwarded = false,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final forwardChatId = appController.getChatId(currentUser.uid, receiverId);
    final messageId = FirebaseFirestore.instance.collection('temp').doc().id;

    final messageData = {
      'id': messageId,
      'senderId': currentUser.uid,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
      'type': type,
      'content': content,

      'forwarded': forwarded,

      'reaction': '',

      'isRead': false,

    };


    await FirebaseFirestore.instance
        .collection('chats')
        .doc(forwardChatId)
        .collection('messages')
        .doc(messageId)
        .set(messageData);
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

                    data['id'] = msg.id;
                    if (data['type'] == null || data['content'] == null) {
                      return const SizedBox.shrink();
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
                          onReact: (emoji) async {
                            await FirebaseFirestore.instance
                                .collection('chats')
                                .doc(chatId)
                                .collection('messages')
                                .doc(data['id'])
                                .update({'reaction': emoji});
                          },
                          onReply: (msg) => setState(() => replyMessage = msg),
                          onForward: (msg) => handleForward(msg),
                          onDeleteForMe: (msg) => deleteMessageForMe(msg),
                          onUnsend: (msg) => unsendMessage(msg),
                          onSwipeToReply: (message) {
                            setState(() {
                              replyMessage = {
                                'senderId': message['senderId'],
                                'content': message['content'],
                                'type': message['type'],
                              };
                            });
                          },

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
          ChatInputBar(
            receiverId: widget.receiverId,
            replyMessage: replyMessage,
            onClearReply: () {
              setState(() => replyMessage = null);
            },
          ),
        ],
      ),
    );
  }
}
