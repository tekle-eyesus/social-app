class UserModel {
  final String uid;
  final String email;
  final String username;
  final String profession;
  final String profilePic;
  final DateTime joinedAt;
  final String bio;
  final int followersCount;
  final int followingCount;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.profession,
    required this.profilePic,
    required this.joinedAt,
    this.bio = "",
    this.followersCount = 0,
    this.followingCount = 0,
  });

  // Factory: Create a UserModel from a Firestore Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      profession: map['profession'] ?? '',
      profilePic: map['profilePic'] ?? '',
      bio: map['bio'] ?? '',
      followersCount: map['followersCount'] ?? 0,
      followingCount: map['followingCount'] ?? 0,
      joinedAt: map['joinedAt'] != null
          ? DateTime.parse(map['joinedAt'])
          : DateTime.now(),
    );
  }

  // ToMap: Convert UserModel to Map for saving to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'profession': profession,
      'profilePic': profilePic,
      'bio': bio,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'joinedAt': joinedAt,
    };
  }
}
