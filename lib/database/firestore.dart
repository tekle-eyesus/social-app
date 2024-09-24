import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
