import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PostStats extends StatelessWidget {
  final void Function()? onTap;
  final IconData icon;
  final String value;
  const PostStats(
      {super.key, this.onTap, required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(onPressed: () {}, icon: Icon(icon)),
        Text(value),
      ],
    );
  }
}
