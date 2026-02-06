import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/helpers/helper_functions.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final Color primaryBlue = const Color.fromARGB(255, 16, 33, 143);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        showCustomSnackbar(
          context,
          "Reset Link sent successfully! Please check your email.",
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Error: ${e.code}";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with that email.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format.";
      }

      if (mounted) {
        showCustomSnackbar(context, errorMessage);
      }
    } catch (e) {
      if (mounted) {
        // CustomSnackBar.showError(context, "Error: ${e.toString()}");
        showCustomSnackbar(
          context,
          "An unexpected error occurred. Please try again later.",
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.lock_reset, color: primaryBlue, size: 28),
                const SizedBox(width: 10),
                const Text(
                  "Forgot Password",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Please enter your email address to receive a password reset link.",
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Email Input
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email Address",
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter your email address.";
                }
                if (!value.contains('@')) {
                  return "Please enter a valid email address.";
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Reset Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Send Reset Link",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
