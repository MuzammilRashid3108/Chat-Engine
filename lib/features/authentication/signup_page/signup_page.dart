
import 'package:chat_engine/common/widgets/authentication/authentication_buttons.dart';
import 'package:chat_engine/common/widgets/authentication/devider.dart';
import 'package:chat_engine/features/authentication/signup_page/signup_form.dart';
import 'package:chat_engine/utils/constants/sizes.dart';
import 'package:chat_engine/utils/constants/text_strings.dart';
import 'package:chat_engine/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: Colors.black,

      // ignore: prefer_const_constructors
      body: SingleChildScrollView(
        child: Column(
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
                          textStyle:
                              TextStyle(color: Colors.white, fontSize: 18),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 28,),
            Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 20, left: 20),
              child: Text(
                AppTextStrings.signupTitle,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(color: Colors.white, fontSize: 24)),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(
              height: AppSizes.paddingExLarge,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SignupForm(dark: dark),
            ),
            const SizedBox(
              height: AppSizes.marginLarge,
            ),
            Devider( dividerText: "Or Sign Up With",color: Colors.white,),
            const SizedBox(
              height: AppSizes.marginLarge,
            ),
            const AuthenticationButtons()
          ],
        ),
      ),
    );
  }
}
