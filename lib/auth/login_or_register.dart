import 'package:flutter/material.dart';
import 'package:socialapp/screens/login_screen.dart';
import 'package:socialapp/screens/register_screen.dart';

class LoginOrRegiter extends StatefulWidget {
  const LoginOrRegiter({super.key});

  @override
  State<LoginOrRegiter> createState() => _LoginOrRegiter();
}

class _LoginOrRegiter extends State<LoginOrRegiter> {
  bool showLoginPage = true;
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginScreen(onTap: togglePages);
    } else {
      return RegisterScreen(onTap: togglePages);
    }
  }
}
