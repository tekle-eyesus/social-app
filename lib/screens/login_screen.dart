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
          email: emailController.text, password: passwordController.text);
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      DisplayErrorMessage(e.code, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: Colors.blue.shade100,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/logo2.png",
                width: 100,
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                "R I N G",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                    fontFamily: 'poppins'),
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextfield(
                  hintText: "Email Address",
                  obscureText: false,
                  controller: emailController),
              const SizedBox(
                height: 10,
              ),
              CustomTextfield(
                  hintText: "password",
                  obscureText: true,
                  controller: passwordController),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              MyButton(
                text: "Login",
                onTap: handleLogIn,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                        // color: Theme.of(context).colorScheme.inversePrimary,
                        fontFamily: 'poppins'),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Register Here",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'poppins',
                          color: Color.fromARGB(255, 1, 95, 173)),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
