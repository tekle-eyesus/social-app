import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/my_button.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;
  RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController usernameController = TextEditingController();

  final TextEditingController confirmPassController = TextEditingController();

  Future<void> addUserToDB(UserCredential? userData) async {
    if (userData?.user != null && userData != null) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection("users").doc(userData.user?.email).set({
        "email": userData.user?.email,
        "username": usernameController.text,
      }).onError((error, stackTrace) => print(error));
    }
  }

  void handleRegister() async {
    //show progress bar
    showDialog(
        context: context,
        builder: (context) => (const Center(
              child: CircularProgressIndicator(),
            )));
    if (passwordController.text.toString() !=
        confirmPassController.text.toString()) {
      Navigator.pop(context);
      DisplayErrorMessage("Password Don't Match1", context);
    }

    try {
      UserCredential? usercreditial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      addUserToDB(usercreditial);
      if (context.mounted) Navigator.pop(context);
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
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: 100,
                height: 100,
                child: Image.asset(
                  "assets/images/logo2.png",
                  width: 100,
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "R E G I S T ER",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        fontFamily: 'poppins'),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              CustomTextfield(
                  hintText: "username",
                  obscureText: false,
                  controller: usernameController),
              const SizedBox(
                height: 10,
              ),
              CustomTextfield(
                  hintText: "Email",
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
                height: 10,
              ),
              CustomTextfield(
                  hintText: "confirm password",
                  obscureText: true,
                  controller: confirmPassController),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(
                height: 10,
              ),
              MyButton(
                text: "Register",
                onTap: handleRegister,
              ),
              const SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already Registerd?",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      "Login Here",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'poppins',
                          color: Color.fromARGB(255, 5, 31, 163)),
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
