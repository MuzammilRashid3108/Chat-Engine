import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final String senderImageUrl;
  final void Function(String emoji)? onReact;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.senderImageUrl,
    this.onReact,
  });

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch $url');
    }
  }

  void _showReactionPicker(BuildContext context) {
    if (onReact != null) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey.shade900,
        builder: (context) => SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['👍', '❤️', '😂', '😮', '😢', '👏'].map((emoji) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onReact!(emoji);
                },
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 26),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = message['type'];
    final content = message['content'];
    final reaction = message['reaction'];

    Widget innerContent;

    if (type == 'image') {
      innerContent = ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Image.network(
          content,
          width: 160,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const SizedBox(
              width: 160,
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
          const Text('❌ Failed to load image'),
        ),
      );
    } else if (type == 'file') {
      innerContent = GestureDetector(
        onTap: () => _launchURL(content),
        child: const Text(
          '📎 File: Tap to open',
          style: TextStyle(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
            fontSize: 14,
          ),
        ),
      );
    } else {
      innerContent = Text(
        content ?? '',
        style: TextStyle(
          color: isMe ? Colors.white : Colors.white70,
          fontSize: 14,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
          isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
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
              child: GestureDetector(
                onLongPress: () => _showReactionPicker(context),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: type == 'image'
                          ? innerContent
                          : Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: isMe
                              ? Colors.blueAccent
                              : Colors.white12,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft:
                            Radius.circular(isMe ? 16 : 0),
                            bottomRight:
                            Radius.circular(isMe ? 0 : 16),
                          ),
                        ),
                        child: innerContent,
                      ),
                    ),
                    if (reaction != null && reaction.isNotEmpty)
                      Positioned(
                        bottom: 2,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            reaction,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (isMe) const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
