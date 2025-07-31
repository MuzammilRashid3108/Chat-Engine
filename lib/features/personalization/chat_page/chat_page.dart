import 'package:chat_engine/common/widgets/chat_page/chat_input_bar.dart';
import 'package:chat_engine/utils/controller/app_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  ChatPage({Key? key, required this.receiverId}) : super(key: key);

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
  }

  String _formatLastSeen(Timestamp? timestamp) {
    if (timestamp == null) return 'Last seen: unknown';
    final DateTime lastSeen = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(lastSeen);
    if (difference.inMinutes < 1) return 'Last seen just now';
    if (difference.inMinutes < 60) return 'Last seen ${difference.inMinutes} min ago';
    if (difference.inHours < 24) return 'Last seen ${difference.inHours} hr ago';
    if (difference.inDays == 1) return 'Last seen yesterday';
    return 'Last seen on ${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('MMM d, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    final receiverName = receiverData?.get('name') ?? 'Loading...';
    final photoUrl = receiverData?.get('photoUrl');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: photoUrl != null && photoUrl != ''
                  ? NetworkImage(photoUrl)
                  : const AssetImage('assets/images/profile.jpeg') as ImageProvider,
              radius: 14,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiverName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatLastSeen(receiverData?.get('lastSeen')),
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ],
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

                // Auto scroll to bottom when messages load
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
                    final timestamp = data['timestamp'] as Timestamp?;
                    final isMe = data['senderId'] == currentUserId;

                    final messageWidget = Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF0084FF) : const Color(0xFF2C2F33),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        data['text'],
                        style: const TextStyle(color: Colors.white),
                      ),
                    );

                    return Column(
                      crossAxisAlignment:
                      isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if ((index + 1) % 10 == 0 && timestamp != null)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Text(
                                _formatTimestamp(timestamp),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        Align(
                          alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: messageWidget,
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
