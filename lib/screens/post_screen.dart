import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialapp/helpers/snackbar_helper.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();

  // UX State variables
  bool _isPosting = false;
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? _userProfilePic;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch user profile mainly to show the Avatar next to the text box
  void _fetchUserProfile() async {
    if (currentUser != null) {
      var doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(currentUser!.email)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userProfilePic = doc.data()?['profilePic'];
        });
      }
    }
  }

  Future pickImage(String source) async {
    final pickedFile = await picker.pickImage(
        source: source == "camera" ? ImageSource.camera : ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  void removeImage() {
    setState(() {
      _image = null;
    });
  }

  // Refactored: Uploads image and returns URL (or null)
  Future<String?> uploadImage(File image) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  void handlePost() async {
    if (_messageController.text.isEmpty && _image == null) {
      CustomSnackBar.showWarning(
        context,
        "Please add a message or an image before posting.",
      );
      return;
    }

    // 1. SET LOADING STATE
    setState(() {
      _isPosting = true;
    });

    try {
      FirebaseFirestore db = FirebaseFirestore.instance;

      // Get fresh user data to ensure profession/name are up to date
      DocumentSnapshot userDoc =
          await db.collection("users").doc(currentUser!.email).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String? imageUrl;

      // 2. UPLOAD IMAGE IF EXISTS
      if (_image != null) {
        imageUrl = await uploadImage(_image!);
      }

      // 3. CREATE POST DOCUMENT
      await db.collection("posts").add({
        "imageUrl": imageUrl, // Can be null now, handled by UI later
        "content": _messageController.text,
        "email": currentUser!.email,
        "profession": userData["profession"] ?? "User",
        "username": userData['username'],
        "profile": userData['profilePic'],
        "likesCount": 0,
        "commentsCount": 0,
        "likedBy": [],
        "timeStamp": DateTime.now().toIso8601String(),
      });

      // 4. RESET UI
      if (mounted) {
        _messageController.clear();
        setState(() {
          _image = null;
          _isPosting = false;
        });
// go back logic
        CustomSnackBar.showSuccess(
          context,
          "Posted successfully!",
        );
      }
    } catch (e) {
      setState(() {
        _isPosting = false;
      });
      CustomSnackBar.showError(
        context,
        "Failed to post. Please try again.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          "Create Post",
          style: TextStyle(
              color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          // MODERN POST BUTTON
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
              onPressed: _isPosting ? null : handlePost,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20),
              ),
              child: _isPosting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "Post",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          if (_isPosting)
            const LinearProgressIndicator(
                minHeight: 2, color: Colors.blueAccent),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // USER AVATAR
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: _userProfilePic != null
                        ? NetworkImage(_userProfilePic!)
                        : null,
                    child: _userProfilePic == null
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),

                  // INPUT AREA
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _messageController,
                          enabled: !_isPosting,
                          maxLines: null, // Auto expand
                          style: TextStyle(fontSize: 18, color: textColor),
                          decoration: InputDecoration(
                            hintText: "What's happening?",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            border: InputBorder.none,
                          ),
                        ),

                        const SizedBox(height: 10),

                        // IMAGE PREVIEW
                        if (_image != null)
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _image!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: removeImage,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // BOTTOM TOOLBAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                  top: BorderSide(color: Colors.grey.shade300, width: 0.5)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: _isPosting ? null : () => pickImage("gallery"),
                  icon: const FaIcon(
                    FontAwesomeIcons.image,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  onPressed: _isPosting ? null : () => pickImage("camera"),
                  icon: const FaIcon(
                    FontAwesomeIcons.camera,
                    color: Colors.blueAccent,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
