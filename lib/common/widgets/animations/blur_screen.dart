import 'dart:math';
import 'package:flutter/material.dart';

class SnakeLikeFlyingPlane extends StatefulWidget {
  const SnakeLikeFlyingPlane({super.key});

  @override
  State<SnakeLikeFlyingPlane> createState() => _SnakeLikeFlyingPlaneState();
}

class _SnakeLikeFlyingPlaneState extends State<SnakeLikeFlyingPlane>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Offset _position;
  late double _angle;

  final double _speed = 8.0; // 5x faster
  double _turnRate = 0.05; // More responsive turning
  double _targetAngle = 0.0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _position = const Offset(200, 300);
    _angle = _random.nextDouble() * 2 * pi;
    _targetAngle = _angle;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )
      ..addListener(_update)
      ..repeat();
  }

  void _update() {
    final size = MediaQuery.of(context).size;

    // Occasionally (randomly), pick a new direction
    if (_random.nextDouble() < 0.05) {
      // Turn randomly in any direction
      _targetAngle += (_random.nextDouble() - 0.5) * pi; // ±180 degrees
    }

    // Smooth turning toward targetAngle
    double angleDiff = _targetAngle - _angle;
    angleDiff = atan2(sin(angleDiff), cos(angleDiff)); // Normalize to [-π, π]
    _angle += angleDiff * _turnRate;

    // Update position
    final dx = cos(_angle) * _speed;
    final dy = sin(_angle) * _speed;
    double newX = _position.dx + dx;
    double newY = _position.dy + dy;

    // Screen wrapping
    if (newX < -50) newX = size.width + 50;
    if (newX > size.width + 50) newX = -50;
    if (newY < -50) newY = size.height + 50;
    if (newY > size.height + 50) newY = -50;

    setState(() {
      _position = Offset(newX, newY);
    });
  }

  @override
  void dispose() => _controller.dispose();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomPaint(
        painter: _PlanePainter(_position, _angle),
        child: Container(),
      ),
    );
  }
}

class _PlanePainter extends CustomPainter {
  final Offset position;
  final double angle;

  _PlanePainter(this.position, this.angle);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    canvas.rotate(angle);

    const icon = Icons.send_rounded;
    const iconSize = 48.0;

    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(-iconSize / 2, -iconSize / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PlanePainter oldDelegate) => true;
}
