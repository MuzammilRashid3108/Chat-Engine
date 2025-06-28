import 'package:flutter/material.dart';

class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key, required this.image, this.color, required this.borderColor});
  final String image;
  final Color? color;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 55,
      height: 55,
      decoration: BoxDecoration(
        border: Border.all(color: borderColor ,width: 1),
        borderRadius: BorderRadius.circular(100)
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Image.asset(image,height: 10,width: 10,color: color,),
      ),
    );
  }
}