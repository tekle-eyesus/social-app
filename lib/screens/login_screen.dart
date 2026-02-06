import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/my_button.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;
  const LoginScreen({super.key, required this.onTap});

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
    emailController.dispose();
    passwordController.dispose();
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
                      fontFamily: 'bebas',
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Connect. Share. Feel the vibe ✨",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                  fontFamily: 'bebas',
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

              const SizedBox(height: 15),

              // Forgot password
              const Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Forgot password?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Color.fromARGB(199, 79, 108, 237),
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

              const SizedBox(height: 40),

              // Register
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don’t have an account?",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Register",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w300,
                        color: Color.fromARGB(199, 79, 108, 237),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // social login options
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      "Or continue with",
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: Colors.grey.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google
                  Icon(
                    Icons.g_mobiledata,
                    size: 50,
                    color: Colors.red,
                  ),
                  SizedBox(width: 24),
                  // Apple
                  Icon(Icons.apple, size: 40),
                  SizedBox(width: 24),
                  // Facebook
                  Icon(
                    Icons.facebook,
                    size: 40,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
