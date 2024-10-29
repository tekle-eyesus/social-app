import 'package:flutter/material.dart';
import 'package:socialapp/theme/app_colors.dart';

class ProfileMetaData extends StatelessWidget {
  final IconData icon;
  final String content;

  const ProfileMetaData({super.key, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white,
        ),
        const SizedBox(
          width: 7,
        ),
        Text(
          content,
          style: TextStyle(
            color: AppColors.surface,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
