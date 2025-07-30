import 'package:chat_engine/common/widgets/chat_page/chat_input_bar.dart';
import 'package:chat_engine/utils/controller/app_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatPage extends StatefulWidget {
  final String receiverId;
  ChatPage({Key? key, required this.receiverId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}


class _ChatPageState extends State<ChatPage> {
  final appController = Get.find<AppController>();
  late String chatId;
  @override
  void initState() {
    super.initState();
    final senderId = FirebaseAuth.instance.currentUser!.uid;
    chatId = appController.getChatId(senderId, widget.receiverId);
  }


  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'text': text, 'isMe': true});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage(
                  'assets/images/profile.jpeg'), // Replace with user image
              radius: 14,
            ),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Usama',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 14),
                ),
                Text("Active 2h go",style: TextStyle(color: Colors.grey,fontSize: 12),)
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.phone, color: Colors.white,size: 21,),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(LucideIcons.video, color: Colors.white,size: 21,),
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

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg['senderId'] == FirebaseAuth.instance.currentUser!.uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
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
                          msg['text'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          ChatInputBar(receiverId: widget.receiverId)
        ],
      ),
    );
  }
}
