import 'package:flutter/material.dart';

class HelperFunctions {
  // Validate if an email is valid
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  // Check if a string is not empty and not null
  static bool isNotEmpty(String? input) {
    return input != null && input.isNotEmpty;
  }

  // Check if a number is positive
  static bool isPositive(int number) {
    return number > 0;
  }

  // Convert a string to a boolean (assuming 'true' or 'false' as input)
  static bool stringToBool(String value) {
    return value.toLowerCase() == 'true';
  }

  // Show a SnackBar message
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Check if a device is in dark mode
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Capitalize the first letter of a string
  static String capitalize(String input) {
    if (input.isEmpty) return '';
    return '${input[0].toUpperCase()}${input.substring(1)}';
  }

  // Get screen height
  static double ScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Get screen width
  static double ScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}