import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/auth/model/user_model.dart';
import 'package:socialapp/helpers/snackbar_helper.dart';
import '../services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _professionController;
  late TextEditingController _bioController;

  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill data
    _usernameController = TextEditingController(text: widget.user.username);
    _professionController = TextEditingController(text: widget.user.profession);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _professionController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_usernameController.text.trim().isEmpty) {
      CustomSnackBar.showError(context, "Username cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _profileService.updateProfile(
        uid: widget.user.email, // Using email as ID per your structure
        username: _usernameController.text.trim(),
        profession: _professionController.text.trim(),
        bio: _bioController.text.trim(),
        newImageFile: _pickedImage,
        currentImageUrl: widget.user.profilePic,
      );

      if (mounted) {
        CustomSnackBar.showSuccess(context, "Profile updated successfully");
        Navigator.pop(context); // Return to profile screen
      }
    } catch (e) {
      if (mounted) {
        CustomSnackBar.showError(context, "Failed to update: $e");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine image provider: File (new) or Network (existing)
    ImageProvider imageProvider;
    if (_pickedImage != null) {
      imageProvider = FileImage(_pickedImage!);
    } else {
      imageProvider = NetworkImage(widget.user.profilePic);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Edit Profile",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.blue))
                : const Text("Save",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade100,
                      backgroundImage: imageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const FaIcon(FontAwesomeIcons.camera,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Change Photo",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),

            const SizedBox(height: 30),

            // 2. Read-Only Email Field
            _buildTextField(
              label: "Email",
              initialValue: widget.user.email,
              readOnly: true,
            ),

            const SizedBox(height: 20),

            // 3. Editable Fields
            _buildInput(label: "Username", controller: _usernameController),
            const SizedBox(height: 20),
            _buildInput(label: "Profession", controller: _professionController),
            const SizedBox(height: 20),
            _buildInput(label: "Bio", controller: _bioController, maxLines: 3),
          ],
        ),
      ),
    );
  }

  // Helper widget for editable inputs
  Widget _buildInput({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget for Read-Only fields
  Widget _buildTextField(
      {required String label,
      required String initialValue,
      bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade500)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            initialValue,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ),
      ],
    );
  }
}
