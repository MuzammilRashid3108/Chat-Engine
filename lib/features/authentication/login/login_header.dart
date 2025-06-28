import 'package:chat_engine/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'assets/app_logos/logo.png',
                  width: 18,
                  height: 18,
                ),
              ),
              SizedBox(
                width: 6,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Text('Chatbox',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(color: Colors.white, fontSize: 18),
                    )),
              ),
            ],
          ),
        ),
        const SizedBox(height: 55),
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Text(AppTextStrings.loginTitle,
              style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.white, fontSize: 28))),
        ),
        SizedBox(
          height: 6,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Text(AppTextStrings.loginSubTitle,
              style: GoogleFonts.openSans(
                  textStyle: TextStyle(color: Colors.grey, fontSize: 12))),
        ),
      ],
    );
  }
}