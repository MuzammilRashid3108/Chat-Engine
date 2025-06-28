
import 'package:chat_engine/utils/constants/colors.dart';
import 'package:chat_engine/utils/constants/sizes.dart';
import 'package:chat_engine/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class SignupForm extends StatelessWidget {
  const SignupForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  expands: false,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: AppTextStrings.firstName,
                  ),
                ),
              ),
              const SizedBox(
                width: AppSizes.marginMedium,
              ),
              Expanded(
                child: TextFormField(
                  expands: false,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Iconsax.user),
                    labelText: AppTextStrings.lastName,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSizes.marginMedium,
          ),
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.user_edit),
              labelText: AppTextStrings.username,
            ),
          ),
          const SizedBox(
            height: AppSizes.marginMedium,
          ),
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
              prefixIcon: Icon(Iconsax.direct),
              labelText: AppTextStrings.email,
            ),
          ),
          const SizedBox(
            height: AppSizes.marginMedium,
          ),
          TextFormField(
            expands: false,
            decoration: const InputDecoration(
                prefixIcon: Icon(Iconsax.password_check),
                labelText: AppTextStrings.password,
                suffixIcon: Icon(Iconsax.eye_slash)),
          ),
          SizedBox(
            height: AppSizes.marginMedium,
          ),
          Row(
            children: [
              Checkbox(
                value: true,
                visualDensity: VisualDensity.compact,
                onChanged: (value) {},
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5)),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                        text: '${AppTextStrings.iAgreeTo} ',
                        style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                          color: Colors.white,
                        ))),
                    TextSpan(
                      text: '${AppTextStrings.privacyPolicy} ',
                      style: GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.grey))
                          .apply(

                              // decoration: TextDecoration.underline,
                              decorationColor:
                                  dark ? AppColors.dark : AppColors.light),
                    ),
                    TextSpan(
                        text: '${AppTextStrings.and} ',
                        style:  GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.white))),
                    TextSpan(
                      text: '${AppTextStrings.termsOfUse}',
                      style:  GoogleFonts.openSans(
                              textStyle: TextStyle(color: Colors.grey)).apply(
                          
                          // decoration: TextDecoration.underline,
                          decorationColor:
                              dark ? AppColors.dark : AppColors.light),
                    ),
                  ],
                ),
              )
            ],
          ),
          SizedBox(
            height: AppSizes.marginMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                onPressed: () {},
                child: Text(
                  AppTextStrings.createAccount,
                )),
          )
        ],
      ),
    );
  }
}
