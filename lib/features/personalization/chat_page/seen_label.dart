import 'package:flutter/material.dart';

class SeenLabel extends StatelessWidget {
  final bool isLastMessage;
  final bool isRead;

  const SeenLabel({
    Key? key,
    required this.isLastMessage,
    required this.isRead,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isLastMessage || !isRead) return const SizedBox.shrink();
    return const Padding(
      padding: EdgeInsets.only(top: 2, right: 6),
      child: Text(
        'Seen',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 10,
        ),
      ),
    );
  }
}
