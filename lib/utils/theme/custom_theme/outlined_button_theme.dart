import 'package:flutter/material.dart';

class MOutlinedButtonTheme {
  static OutlinedButtonThemeData lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.black,
      side: BorderSide(color: Colors.grey),
      textStyle: TextStyle(fontSize: 16,color: Colors.black,fontWeight: FontWeight.w600),
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
    )
  );

   static OutlinedButtonThemeData darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: Colors.white,
      side: BorderSide(color: Colors.grey),
      textStyle: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.w600),
      padding: EdgeInsets.symmetric(horizontal: 20,vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))
    )
  );
}