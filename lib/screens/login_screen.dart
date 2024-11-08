import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/my_button.dart';
import 'package:socialapp/widget/signup.dart';

class LoginScreen extends StatefulWidget {
  final void Function()? onTap;
  LoginScreen({super.key, required this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
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
      // DisplayErrorMessage(e.code, context);
      showCustomSnackbar(context, e.code);
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: 1,
      duration: const Duration(
        milliseconds: 900,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: Color.fromARGB(255, 6, 16, 88),
      appBar: AppBar(
        title: Text("VibeHub",
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Color.fromARGB(255, 6, 16, 88),
                  fontFamily: 'poppins',
                  fontSize: 36,
                )),
        toolbarHeight: 100,
        titleSpacing: 7,
        backgroundColor: Colors.blue.shade500,
        bottom: PreferredSize(
            preferredSize: Size(double.infinity, 50),
            child: Container(
              width: double.infinity,
              height: 70,
              color: Color.fromARGB(255, 6, 16, 88),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                child: Text("CONNECT",
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Colors.white,
                          fontFamily: 'sofa',
                          fontSize: 20,
                        )),
              ),
            )),
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(100 * _animationController.value),
              ),
              color: Colors.blue.shade100,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    "assets/images/illu1.png",
                    height: 150,
                  ),
                  const SizedBox(
                    height: 15,
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
                    height: 25,
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
                    height: 39,
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
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
