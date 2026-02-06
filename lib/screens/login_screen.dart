import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/my_button.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;
  LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleLogIn() async {
    showDialog(
        context: context,
        builder: (context) => (const Center(
              child: CircularProgressIndicator(),
            )));

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      // DisplayErrorMessage(e.code, context);
      showCustomSnackbar(context, e.code);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // App Title
              Text(
                "VibeHub",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                "Connect. Share. Feel the vibe ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                  fontFamily: 'poppins',
                ),
              ),

              const SizedBox(height: 40),

              // Illustration
              Image.asset(
                "assets/images/illu1.png",
                height: 160,
              ),

              const SizedBox(height: 32),

              // Email
              CustomTextfield(
                hintText: "Email Address",
                obscureText: false,
                controller: emailController,
              ),

              const SizedBox(height: 14),

              // Password
              CustomTextfield(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 12),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF4F6BED),
                    fontFamily: 'poppins',
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Login Button
              SizedBox(
                height: 60,
                child: MyButton(
                  text: "Login",
                  onTap: handleLogIn,
                ),
              ),

              const SizedBox(height: 28),

              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4F6BED),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
