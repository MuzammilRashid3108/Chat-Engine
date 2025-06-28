import 'package:chat_engine/utils/constants/colors.dart';
import 'package:chat_engine/utils/theme/custom_theme/check_box_theme.dart';
import 'package:chat_engine/utils/theme/custom_theme/elevated_button_theme.dart';
import 'package:chat_engine/utils/theme/custom_theme/outlined_button_theme.dart';
import 'package:chat_engine/utils/theme/custom_theme/thext_field_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    inputDecorationTheme: MTexFieldTheme.lightInputDecorationTheme,
    checkboxTheme: MCheckBoxTheme.lightCheckBoxTheme,
    elevatedButtonTheme: MElevatedButtonTheme.lightElevatedButtonTheme,
    outlinedButtonTheme: MOutlinedButtonTheme.darkOutlinedButtonTheme,
  );
  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.background,
    inputDecorationTheme: MTexFieldTheme.darkInputDecorationTheme,
    checkboxTheme: MCheckBoxTheme.darkCheckBoxTheme,
    elevatedButtonTheme: MElevatedButtonTheme.darkElevatedButtonTheme,
    outlinedButtonTheme: MOutlinedButtonTheme.darkOutlinedButtonTheme,
  );
}
