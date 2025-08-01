import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final String senderImageUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.senderImageUrl,
  });

  Widget _buildMessageContent() {
    final type = message['type'];
    final content = message['content'];

    if (type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          content,
          width: 160,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 200,
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
          const Text('❌ Failed to load image'),
        ),
      );
    } else if (type == 'file') {
      return GestureDetector(
        onTap: () => _launchURL(content),
        child: Text(
          '📎 File: Tap to open',
          style: const TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
            fontSize: 14,
          ),
        ),
      );
    } else {
      return Text(
        content ?? '',
        style: TextStyle(
          color: isMe ? Colors.white : Colors.white70,
          fontSize: 14,
        ),
      );
    }
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = message['type'];

    final messageContent = _buildMessageContent();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe)
              CircleAvatar(
                radius: 15,
                backgroundImage: senderImageUrl.isNotEmpty
                    ? NetworkImage(senderImageUrl)
                    : const AssetImage('assets/images/no_profile.webp')
                as ImageProvider,
              ),
            if (!isMe) const SizedBox(width: 8),
            Flexible(
              child: type == 'image'
                  ? messageContent // 🟢 No border/container for images
                  : Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: isMe ? Colors.blueAccent : Colors.white12,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 0),
                    bottomRight: Radius.circular(isMe ? 0 : 16),
                  ),
                ),
                child: messageContent,
              ),
            ),
            if (isMe) const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
