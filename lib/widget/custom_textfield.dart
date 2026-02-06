import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String hintText;
  bool obscureText;
  final TextEditingController controller;
  CustomTextfield(
      {super.key,
      required this.hintText,
      required this.obscureText,
      required this.controller});

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  _toggleObscureText() {
    if (widget.obscureText) {
      widget.obscureText = false;
    } else {
      widget.obscureText = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.6),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        suffixIcon: widget.hintText.contains("Password")
            ? IconButton(
                onPressed: _toggleObscureText,
                icon: const Icon(
                  Icons.visibility_off,
                  color: Colors.grey,
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
