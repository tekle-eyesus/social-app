import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfileService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final cloudinary = CloudinaryPublic(dotenv.env['CLOUDINARY_CLOUD_NAME']!,
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
      cache: false);

  Future<void> updateProfile({
    required String uid,
    required String username,
    required String profession,
    required String bio,
    File? newImageFile,
    required String currentImageUrl,
  }) async {
    String finalImageUrl = currentImageUrl;

    // 1. If a new image was picked, upload it first
    if (newImageFile != null) {
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(newImageFile.path,
              resourceType: CloudinaryResourceType.Image),
        );
        finalImageUrl = response.secureUrl;
      } catch (e) {
        throw Exception("Image upload failed: $e");
      }
    }

    // 2. Update Firestore
    await _db.collection('users').doc(uid).update({
      'username': username,
      'profession': profession,
      'bio': bio,
      'profilePic': finalImageUrl,
    });
  }
}
