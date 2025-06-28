import 'package:chat_engine/utils/constants/sizes.dart';
import 'package:flutter/material.dart';

class AuthenticationButtons extends StatelessWidget {
  const AuthenticationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              image: AssetImage("assets/auth_logos/google.png"),
              height: 24,
              width: 24,
            ),
          ),
        ),
        const SizedBox(width: AppSizes.marginMedium),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Image(
              image: AssetImage("assets/auth_logos/facebook.png"),
              height: 24,
              width: 24,
            ),
          ),
        ),
      ],
    );
  }
}
