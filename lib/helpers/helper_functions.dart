import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

String timeAgoFromString(String timestampString) {
  try {
    // Parse the timestamp string to DateTime
    DateTime postDate = DateTime.parse(timestampString);
    Duration difference = DateTime.now().difference(postDate);

    if (difference.inSeconds < 60) {
      return "${difference.inSeconds}s ago";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hr ago";
    } else if (difference.inDays < 7) {
      return "${difference.inDays} days ago";
    } else if (difference.inDays < 30) {
      return "${(difference.inDays / 7).floor()} week(s) ago";
    } else if (difference.inDays < 365) {
      return "${(difference.inDays / 30).floor()} month(s) ago";
    } else {
      return "${(difference.inDays / 365).floor()} year(s) ago";
    }
  } catch (e) {
    // Handle any parsing errors or invalid timestamp format
    print("Error parsing timestamp: $e");
    return "Invalid date";
  }
}

/// Helper function to retrieve the current user's information from Firestore.
/// Returns a [Map<String, dynamic>] containing the user information or `null` if not found.
Future<Map<String, dynamic>?> fetchCurrentUserInfo() async {
  try {
    // Get the current user's email from FirebaseAuth
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Check if the user is logged in
    if (currentUser == null || currentUser.email == null) {
      print("No logged-in user found.");
      return null;
    }

    String userEmail = currentUser.email!;

    // Fetch user data from Firestore based on email
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection(
            'users') // Assume the user data is in the 'users' collection
        .doc(userEmail)
        .get();

    // Check if the document exists
    if (!userDoc.exists) {
      print("User document not found.");
      return null;
    }

    // Return user data as a Map
    return userDoc.data() as Map<String, dynamic>;
  } catch (e) {
    print("Error fetching user info: $e");
    return null;
  }
}
