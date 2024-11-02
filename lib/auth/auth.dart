import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/auth/login_or_register.dart';
import 'package:socialapp/screens/HomeScreen.dart';
import 'package:socialapp/screens/tab_screen.dart';

class AuthUser extends StatelessWidget {
  const AuthUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return TabScreen();
          } else {
            return const LoginOrRegiter();
          }
        },
      ),
    );
  }
}
