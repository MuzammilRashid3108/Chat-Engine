import 'package:chat_engine/common/widgets/authentication/authentication_buttons.dart';
import 'package:chat_engine/common/widgets/authentication/devider.dart';
import 'package:chat_engine/features/authentication/login/login_form.dart';
import 'package:chat_engine/features/authentication/login/login_header.dart';
import 'package:chat_engine/utils/constants/sizes.dart';
import 'package:chat_engine/utils/constants/text_strings.dart';
import 'package:chat_engine/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // LoginHeader
            LoginHeader(dark: dark),

            //LoginForm
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: LoginForm(),
            ),

            //Devider
            Devider(dividerText: AppTextStrings.signinOptions.capitalize!,color: Colors.white,),

            //Aunthentication Buttons
            const SizedBox(height: AppSizes.paddingExLarge),

            const AuthenticationButtons(),
          ],
        ),
      ),
    );
  }
}
