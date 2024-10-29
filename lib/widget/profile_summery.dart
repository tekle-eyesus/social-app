import 'package:flutter/material.dart';
import 'package:socialapp/theme/app_colors.dart';

class ProfileSummery extends StatelessWidget {
  final String title;
  final int amount;
  const ProfileSummery({super.key, required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          amount.toString(),
          style: TextStyle(
            color: AppColors.primaryText,
            fontSize: 29,
            fontFamily: 'poppins',
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}
