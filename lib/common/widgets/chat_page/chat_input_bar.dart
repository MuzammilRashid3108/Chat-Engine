import 'package:chat_engine/utils/controller/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatInputBar extends StatefulWidget {
  final String receiverId;

  const ChatInputBar({super.key, required this.receiverId});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  final appController = Get.find<AppController>();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    appController.sendMessage(
      receiverId: widget.receiverId,
      messageText: text,
    );

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: Colors.black,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: const CircleAvatar(
              backgroundColor: Color(0xFF0084FF),
              child: Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
