import 'package:flutter/material.dart';
import 'last_seen_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAvatarWithName extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final Timestamp? lastSeen;
  final bool isOnline;

  const UserAvatarWithName({
    Key? key,
    required this.name,
    this.photoUrl,
    this.lastSeen,
    this.isOnline = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: photoUrl != null && photoUrl != ''
              ? NetworkImage(photoUrl!)
              : const AssetImage('assets/images/profile.jpeg') as ImageProvider,
          radius: 14,
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            LastSeenText(lastSeen: lastSeen, isOnline: isOnline),
          ],
        ),
      ],
    );
  }
}
