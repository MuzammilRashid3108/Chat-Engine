import 'package:chat_engine/features/authentication/welcome_page/animated_blur_screen.dart';
import 'package:chat_engine/common/widgets/authentication/auth_buttons.dart';
import 'package:chat_engine/common/widgets/authentication/devider.dart';
import 'package:chat_engine/utils/controller/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomePage extends StatelessWidget {
  final appController = Get.put(AppController());
  WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBlurScreen(),
          Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                    SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(top: 18),
                      child: Text(
                        'Chat Engine',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 28),
                RichText(
                  text: TextSpan(
                    text: 'Connect\nfriends\n',
                    style: GoogleFonts.openSans(
                      textStyle: TextStyle(color: Colors.white, fontSize: 60),
                    ),
                    children: [
                      TextSpan(
                        text: 'easily &\nquickly',
                        style: GoogleFonts.openSans(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 60,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  'Our chat app is the best way to stay\nconnected with friends and damily.',
                  style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                      color: Color(0xffB9C1BE),
                      fontSize: 16,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                ),
                SizedBox(height: 18),
                Row(
                  spacing: 24,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        appController.signInWithGoogle();
                      },
                      child: AuthButtons(
                        borderColor: Colors.white,
                        image: 'assets/auth_logos/google.png',
                      ),
                    ),
                    AuthButtons(
                      borderColor: Colors.white,
                      image: 'assets/auth_logos/facebook.png',
                    ),
                  ],
                ),
                SizedBox(height: 18),
                Devider(dividerText: "OR", color: Colors.white),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Theme(
                      data: ThemeData.light(),
                      child: ElevatedButton(
                        onPressed: () {
                          appController.goToLoginPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Log In",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Theme(
                      data: ThemeData.light(),
                      child: ElevatedButton(
                        onPressed: () {
                          appController.goToSigunUpPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Sign Up",
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
