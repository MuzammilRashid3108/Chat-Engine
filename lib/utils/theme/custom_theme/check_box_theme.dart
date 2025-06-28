import 'package:flutter/material.dart';

class MCheckBoxTheme {
  static CheckboxThemeData lightCheckBoxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),
    visualDensity: VisualDensity.compact,
    checkColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        else{
          return Colors.black;
        }
      },
    ),
    fillColor:  WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return Color(0xff43116A);
        }
        else{
          return Colors.transparent;
        }
      },
    ),
  );

   static CheckboxThemeData darkCheckBoxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    checkColor: WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        else{
          return Colors.black;
        }
      },
    ),
    fillColor:  WidgetStateProperty.resolveWith(
      (states) {
        if (states.contains(WidgetState.selected)) {
          return Color(0xff43116A);
        }
        else{
          return Colors.transparent;
        }
      },
    ),
  );
}