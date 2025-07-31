import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimestampLabel extends StatelessWidget {
  final Timestamp timestamp;

  const TimestampLabel({Key? key, required this.timestamp}) : super(key: key);

  String _format(Timestamp ts) {
    return DateFormat('MMM d, hh:mm a').format(ts.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          _format(timestamp),
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
      ),
    );
  }
}
