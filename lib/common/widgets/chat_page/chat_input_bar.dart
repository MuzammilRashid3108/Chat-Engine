import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key});

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _controller = TextEditingController();
  bool showSend = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        showSend = _controller.text.trim().isNotEmpty;
      });
    });
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  // Camera Icon
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(35),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 10),

                  // TextField
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  Icon(LucideIcons.image, color: Colors.white),
                  const SizedBox(width: 12),
                  // Action Icon: Mic or Send
                  GestureDetector(
                    onTap: () {
                      if (showSend) {
                        print('Send: ${_controller.text}');
                        _controller.clear();
                      } else {
                        print('Mic pressed');
                      }
                    },
                    child: Icon(
                      showSend ? Icons.send : LucideIcons.mic,
                      color: Colors.white,
                    ),
                  ),


                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
