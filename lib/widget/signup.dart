import 'package:flutter/material.dart';

class AuthComponenet extends StatelessWidget {
  final void Function()? onTap;
  final IconData icon;
  final Color iconColor;
  const AuthComponenet(
      {super.key, this.onTap, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 33, 38, 183),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 40,
        ),
      ),
    );
  }
}
