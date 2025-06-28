import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class AnimatedBlurScreen extends StatefulWidget {
  const AnimatedBlurScreen({super.key});

  @override
  State<AnimatedBlurScreen> createState() => _AnimatedBlurScreenState();
}

class _AnimatedBlurScreenState extends State<AnimatedBlurScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Message sending animation: chat bubbles moving upward and fading
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double t = _controller.value;
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _MessageBubblePainter(t),
              );
            },
          ),
          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
              child: Container(
                color: Colors.black.withOpacity(0.08),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubblePainter extends CustomPainter {
  final double t;
  _MessageBubblePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);
    for (int i = 0; i < 10; i++) {
      final baseX = 40.0 + random.nextDouble() * (size.width - 80);
      final startY = size.height + 60.0 * i;
      final progress = (t + i * 0.1) % 1.0;
      final y = startY - progress * (size.height + 120);
      final opacity = (1.0 - progress).clamp(0.0, 1.0);
      final isUser = i % 2 == 0;
      final bubbleWidth = 120.0 + random.nextDouble() * 60.0;
      final bubbleHeight = 38.0 + random.nextDouble() * 10.0;
      final bubbleColor = isUser
          ? Colors.blueAccent.withOpacity(0.18 * opacity + 0.12)
          : Colors.amberAccent.withOpacity(0.18 * opacity + 0.12);
      final r = RRect.fromLTRBR(
        baseX,
        y,
        baseX + bubbleWidth,
        y + bubbleHeight,
        Radius.circular(22),
      );
      final paint = Paint()
        ..color = bubbleColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _MessageBubblePainter oldDelegate) => true;
}
