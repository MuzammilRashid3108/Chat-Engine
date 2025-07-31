import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LastSeenText extends StatelessWidget {
  final Timestamp? lastSeen;
  final bool isOnline;

  const LastSeenText({
    Key? key,
    required this.lastSeen,
    this.isOnline = false,
  }) : super(key: key);

  String _formatLastSeen(Timestamp? timestamp) {
    if (timestamp == null) return 'Last seen: unknown';
    final DateTime lastSeen = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) return 'Last seen just now';
    if (difference.inMinutes == 1) return 'Last seen 1 min ago';
    if (difference.inMinutes < 60) return 'Last seen ${difference.inMinutes} mins ago';
    if (difference.inHours == 1) return 'Last seen 1 hr ago';
    if (difference.inHours < 24) return 'Last seen ${difference.inHours} hrs ago';
    if (difference.inDays == 1) return 'Last seen yesterday';
    return 'Last seen on ${DateFormat('MMM d, hh:mm a').format(lastSeen)}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      isOnline ? 'Online' : _formatLastSeen(lastSeen),
      style: const TextStyle(color: Colors.white60, fontSize: 12),
    );
  }
}
