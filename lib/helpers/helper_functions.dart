import 'package:flutter/material.dart';

void DisplayErrorMessage(String message, BuildContext context) {
  showDialog(
      context: context,
      builder: (context) => AlertDialog(
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
            backgroundColor: Colors.blue.shade300,
            title: Text(message),
          ));
}
