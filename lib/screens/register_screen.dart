import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/drop_down.dart';
import 'package:socialapp/widget/my_button.dart';
import 'package:socialapp/widget/signup.dart';

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
  String? selectedProfession;
  final List<String> professions = [
    'Software Engineer',
    'Web Developer',
    'Data Scientist',
    'Product Manager',
    'UX/UI Designer',
    'DevOps Engineer',
    'Systems Analyst',
    'Cybersecurity',
    'Cloud Engineer',
    'Machine Learning Engineer',
    'Quality Assurance (QA) Tester',
    'Database Administrator',
    'IT Support Specialist',
    'Mobile App Developer',
    'Technical Writer',
  ];
//add user data to db
  Future<void> addUserToDB(UserCredential? userData) async {
    if (userData?.user != null && userData != null) {
      FirebaseFirestore db = FirebaseFirestore.instance;
      await db.collection("users").doc(userData.user?.email).set({
        "email": userData.user?.email,
        "username": usernameController.text,
        "profession": selectedProfession,
        "profilePic":
            "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQTSKbCFe_QYSVH-4FpaszXvakr2Eti9eAJpQ&s"
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

      showCustomSnackbar(context, "Passwords do not match.");
    }

    try {
      UserCredential? usercreditial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);
      addUserToDB(usercreditial);
      if (context.mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (mounted) Navigator.pop(context);

      showCustomSnackbar(context, e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: const Color.fromARGB(255, 6, 16, 88),
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("REGISTER",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white,
                    // fontFamily: 'poppins',
                    fontSize: 20,
                  )),
        ),
        backgroundColor: const Color.fromARGB(255, 6, 16, 88),
        actions: [
          Image.asset(
            "assets/images/illu3.png",
            height: 60,
          )
        ],
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50),
            ),
          ),
          child: ListView(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              CustomTextfield(
                  hintText: "username",
                  obscureText: false,
                  controller: usernameController),
              const SizedBox(
                height: 15,
              ),
              CustomTextfield(
                  hintText: "Email",
                  obscureText: false,
                  controller: emailController),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    borderRadius: BorderRadius.circular(25),
                    value: selectedProfession,
                    hint: Text(
                      'Select Profession',
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                    icon: const Icon(Icons.arrow_drop_down,
                        color: Colors.blueAccent),
                    isExpanded: true,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                    items: professions.map((String profession) {
                      return DropdownMenuItem<String>(
                        value: profession,
                        child: Text(profession),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProfession = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              CustomTextfield(
                  hintText: "password",
                  obscureText: true,
                  controller: passwordController),
              const SizedBox(
                height: 15,
              ),
              CustomTextfield(
                  hintText: "confirm password",
                  obscureText: true,
                  controller: confirmPassController),
              const SizedBox(
                height: 15,
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
              ),
              const SizedBox(
                height: 35,
              ),
              const Text(
                "~Or, Sign up with~",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 15,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AuthComponenet(
                    icon: FontAwesomeIcons.google,
                    iconColor: Color.fromARGB(255, 29, 163, 33),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  AuthComponenet(
                    icon: FontAwesomeIcons.facebook,
                    iconColor: Colors.white,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  AuthComponenet(
                    icon: FontAwesomeIcons.github,
                    iconColor: Colors.white,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
