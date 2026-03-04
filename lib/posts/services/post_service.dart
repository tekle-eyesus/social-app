import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../models/post_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PostService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final _cloudinary = CloudinaryPublic(dotenv.env['CLOUDINARY_CLOUD_NAME']!,
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
      cache: false);

  Future<void> createPost({
    required User currentUser,
    required String content,
    File? imageFile,
  }) async {
    try {
      DocumentSnapshot userDoc =
          await _db.collection("users").doc(currentUser.email).get();

      if (!userDoc.exists) throw Exception("User profile not found");

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      String? uploadedImageUrl;
      if (imageFile != null) {
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(imageFile.path,
              resourceType: CloudinaryResourceType.Image),
        );
        uploadedImageUrl = response.secureUrl;
      }

      PostModel newPost = PostModel(
        content: content,
        imageUrl: uploadedImageUrl,
        email: currentUser.email!,
        username: userData['username'] ?? 'User',
        profession: userData['profession'] ?? 'Tech Enthusiast',
        authorProfilePic: userData['profilePic'] ?? '',
        timeStamp: DateTime.now().toIso8601String(),
        likesCount: 0,
        commentsCount: 0,
        likedBy: [],
      );

      await _db.collection("posts").add(newPost.toMap());
    } catch (e) {
      throw Exception("Post creation failed: $e");
    }
  }
}
