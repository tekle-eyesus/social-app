import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String? id;
  final String? imageUrl;
  final String content;
  final String email; // Author ID/Email
  final String username;
  final String profession;
  final String
      authorProfilePic; // Saved in DB as 'profile' based on your old code
  final int likesCount;
  final int commentsCount;
  final List<String> likedBy;
  final String timeStamp;

  PostModel({
    this.id,
    this.imageUrl,
    required this.content,
    required this.email,
    required this.username,
    required this.profession,
    required this.authorProfilePic,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedBy = const [],
    required this.timeStamp,
  });

  // Factory: Create a PostModel from Firestore Data
  factory PostModel.fromMap(Map<String, dynamic> map, String docId) {
    return PostModel(
      id: docId,
      imageUrl: map['imageUrl'],
      content: map['content'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? 'Unknown',
      profession: map['profession'] ?? '',
      authorProfilePic: map['profile'] ?? '', // Mapping 'profile' key from DB
      likesCount: map['likesCount'] ?? 0,
      commentsCount: map['commentsCount'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      timeStamp: map['timeStamp'] ?? '',
    );
  }

  // ToMap: Prepare data for writing to Firestore
  Map<String, dynamic> toMap() {
    return {
      "imageUrl": imageUrl,
      "content": content,
      "email": email,
      "username": username,
      "profession": profession,
      "profile": authorProfilePic,
      "likesCount": likesCount,
      "commentsCount": commentsCount,
      "likedBy": likedBy,
      "timeStamp": timeStamp,
    };
  }
}
