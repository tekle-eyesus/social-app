import 'package:flutter/material.dart';

void DisplayErrorMessage(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: Text(message),
          ));
}
