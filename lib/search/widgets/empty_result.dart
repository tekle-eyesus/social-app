import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EmptyResult extends StatelessWidget {
  TextEditingController searchController = TextEditingController();
  EmptyResult({super.key, required TextEditingController searchController})
      : searchController = searchController;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.faceFrownOpen,
              size: 60, color: Colors.grey.shade200),
          const SizedBox(height: 15),
          Text(
            "No user found named \"${searchController.text}\"",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
