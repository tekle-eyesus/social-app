import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/my_button.dart';
import 'package:socialapp/widget/signup.dart';

class RegisterScreen extends StatefulWidget {
  final void Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

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
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              Text(
                "Create Account",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
              ),

              const SizedBox(height: 6),

              Text(
                "Join the vibe and start connecting 🚀",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              Image.asset(
                "assets/images/illu3.png",
                height: 150,
              ),

              const SizedBox(height: 32),

              CustomTextfield(
                hintText: "Username",
                obscureText: false,
                controller: usernameController,
              ),

              const SizedBox(height: 14),

              CustomTextfield(
                hintText: "Email address",
                obscureText: false,
                controller: emailController,
              ),

              const SizedBox(height: 14),

              // Profession Dropdown (Styled like TextField)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedProfession,
                    hint: Text(
                      "Select profession",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        color: const Color(0xFF9CA3AF),
                      ),
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF4F6BED),
                    ),
                    isExpanded: true,
                    items: professions.map((profession) {
                      return DropdownMenuItem(
                        value: profession,
                        child: Text(
                          profession,
                          style: const TextStyle(fontFamily: 'poppins'),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedProfession = value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              CustomTextfield(
                hintText: "Password",
                obscureText: true,
                controller: passwordController,
              ),

              const SizedBox(height: 14),

              CustomTextfield(
                hintText: "Confirm password",
                obscureText: true,
                controller: confirmPassController,
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 52,
                child: MyButton(
                  text: "Create Account",
                  onTap: handleRegister,
                ),
              ),

              const SizedBox(height: 24),

              // Login redirect
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account?",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: Text(
                      "Login",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4F6BED),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: const [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text("or sign up with"),
                  ),
                  Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 20),

              // Social buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  AuthComponenet(
                    icon: FontAwesomeIcons.google,
                    iconColor: Color(0xFFDB4437),
                  ),
                  SizedBox(width: 16),
                  AuthComponenet(
                    icon: FontAwesomeIcons.facebook,
                    iconColor: Color(0xFF1877F2),
                  ),
                  SizedBox(width: 16),
                  AuthComponenet(
                    icon: FontAwesomeIcons.github,
                    iconColor: Colors.black,
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
