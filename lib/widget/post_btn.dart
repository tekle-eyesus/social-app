import 'package:flutter/material.dart';

class PostButton extends StatelessWidget {
  final void Function() onTap;
  final IconData icon;
  const PostButton({super.key, required this.onTap, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.blue.shade500,
        ),
        child: Icon(
          Icons.post_add,
        ),
      ),
    );
  }
}
