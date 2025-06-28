import 'package:flutter/material.dart';


import '../../../utils/constants/colors.dart';

class Devider extends StatelessWidget {
  const Devider({
    super.key,
    // required this.dark,
    required this.dividerText,  this.color,
  });  
  

  // final bool dark;
  final String dividerText;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Divider(
              color: AppColors.divider,
              thickness: 0.5,
              indent: 30,
              endIndent: 10),
        ),
        Text(
          dividerText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
        ),
        Flexible(
          child: Divider(
            color: AppColors.divider,
            thickness: 0.5,
            indent: 10,
            endIndent: 30,
          ),
        ),
      ],
    );
  }
}