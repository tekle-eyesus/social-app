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

void showCustomSnackbar(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor: Colors.blueGrey.shade900,
    behavior: SnackBarBehavior.floating, // Makes it float above the bottom.
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    duration:
        Duration(seconds: 3), // Controls how long the Snackbar is displayed.
    action: SnackBarAction(
      label: 'DISMISS',
      textColor: Colors.orangeAccent,
      onPressed: () {
        // Dismiss the snackbar or take any action.
      },
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
