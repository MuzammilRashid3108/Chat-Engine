import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  final bool isMe;
  final String senderImageUrl;
  final void Function(String emoji)? onReact;
  final void Function(Map<String, dynamic> message)? onReply;
  final void Function(Map<String, dynamic> message)? onForward;
  final void Function(Map<String, dynamic> message)? onDeleteForMe;
  final void Function(Map<String, dynamic> message)? onUnsend;
  final Function(Map<String, dynamic> messageData) onSwipeToReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.senderImageUrl,
    this.onReact,
    this.onReply,
    this.onForward,
    this.onDeleteForMe,
    this.onUnsend,
    required this.onSwipeToReply,
  });

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ Could not launch $url');
    }
  }

  void _translateMessage(BuildContext context) {
    const translated = '📘 Translated: This is sample translated text';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Translated', style: TextStyle(color: Colors.white)),
        content: const Text(translated, style: TextStyle(color: Colors.white70)),
      ),
    );
  }

  void _showMessageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['👍', '❤️', '😂', '😮', '😢', '👏'].map((emoji) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    onReact?.call(emoji);
                  },
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                );
              }).toList(),
            ),
          ),
          const Divider(color: Colors.white24),
          _buildOption(context, Icons.reply, 'Reply', () {
            Navigator.pop(context);
            onReply?.call(message);
          }),
          _buildOption(context, Icons.forward, 'Forward', () {
            Navigator.pop(context);
            onForward?.call(message);
          }),
          _buildOption(context, Icons.copy, 'Copy', () {
            Navigator.pop(context);
            Clipboard.setData(ClipboardData(text: message['content'] ?? ''));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Message copied')),
            );
          }),
          _buildOption(context, Icons.translate, 'Translate', () {
            Navigator.pop(context);
            _translateMessage(context);
          }),
          _buildOption(context, Icons.delete_outline, 'Delete for you', () {
            Navigator.pop(context);
            onDeleteForMe?.call(message);
          }),
          if (isMe)
            _buildOption(context, Icons.block, 'Unsend', () {
              Navigator.pop(context);
              onUnsend?.call(message);
            }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final type = message['type'];
    final content = message['content'];
    final reaction = message['reaction'];
    final replyTo = message['repliedTo'];
    final isForwarded = message['forwarded'] == true;

    if (type == 'unsent') {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            content ?? 'You unsent this message',
            style: const TextStyle(
              color: Colors.white54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

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

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (isMe && details.primaryVelocity! < -200) {
          onSwipeToReply(message);
        } else if (!isMe && details.primaryVelocity! > 200) {
          onSwipeToReply(message);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        child: Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe)
                CircleAvatar(
                  radius: 15,
                  backgroundImage: senderImageUrl.isNotEmpty
                      ? NetworkImage(senderImageUrl)
                      : const AssetImage('assets/images/no_profile.webp') as ImageProvider,
                ),
              if (!isMe) const SizedBox(width: 8),
              Flexible(
                child: GestureDetector(
                  onLongPress: () => _showMessageOptions(context),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (replyTo != null)
                              Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(bottom: 4),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade700,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (replyTo['type'] == 'image' && replyTo['content'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.network(
                                          replyTo['content'],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.broken_image, color: Colors.white30),
                                        ),
                                      ),
                                    const SizedBox(height: 6),
                                    if (replyTo['caption'] != null && replyTo['caption'].toString().isNotEmpty)
                                      Text(
                                        replyTo['caption'],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      )
                                    else if (replyTo['type'] != 'image' && replyTo['content'] != null)
                                      Text(
                                        replyTo['content'],
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            if (isForwarded)
                              const Text(
                                'Forwarded',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            type == 'image'
                                ? innerContent
                                : Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.purple : Colors.white12,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                                  bottomRight: Radius.circular(isMe ? 0 : 16),
                                ),
                              ),
                              child: innerContent,
                            ),
                          ],
                        ),
                      ),
                      if (reaction != null && reaction.isNotEmpty)
                        Positioned(
                          bottom: 2,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
      ),
    );
  }
}
