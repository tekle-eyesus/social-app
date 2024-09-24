import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "./../helpers/helper_functions.dart";

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? loggedUser = FirebaseAuth.instance.currentUser;

    Future<Map<String, dynamic>?> getUserData() async {
      FirebaseFirestore db = FirebaseFirestore.instance;
      DocumentSnapshot doc =
          await db.collection("users").doc(loggedUser?.email).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            );
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          } else if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            return Text(data['username']);
          } else {
            return Text("not working....");
          }
        },
      ),
    );
  }
}
