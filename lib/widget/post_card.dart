import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/screens/user_profile_screen.dart';
import 'package:socialapp/services/gemini_chat_service.dart';
import 'package:socialapp/widget/ai_summary.dart';
import 'package:socialapp/widget/comment_sheet.dart';
import 'package:socialapp/widget/full_screen_image.dart';

class PostItem extends StatefulWidget {
  final Map<String, dynamic> postData;
  final String docId;
  final int index;

  const PostItem({
    Key? key,
    required this.postData,
    required this.docId,
    required this.index,
  }) : super(key: key);

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  bool isExpanded = false; // State to handle Read More/Less

  Future<void> likePost(String postId, String userId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    // Check if the user already liked the post
    DocumentSnapshot postSnapshot = await postRef.get();
    List likedBy = postSnapshot['likedBy'] ?? [];

    if (likedBy.contains(userId)) {
      // Unlike the post
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      // Like the post
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  /// COMMENT IMPLEMENTATION
  Future<void> addComment(
      String postId, String userId, String username, String commentText) async {
    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc();

    await commentRef.set({
      'userId': userId,
      'username': username,
      'commentText': commentText,
      'timestamp':
          FieldValue.serverTimestamp(), // Automatically sets the server time.
    });
  }

  @override
  Widget build(BuildContext context) {
    final postData = widget.postData;

    // Extract Logic
    final likeCount = postData['likesCount'] ?? 0;
    final commentCount = postData['commentsCount'] ?? 0;
    final likedBy = List.from(postData['likedBy'] ?? []);
    final userLiked =
        likedBy.contains(FirebaseAuth.instance.currentUser!.email);
    final String content = postData['content'].toString();
    final bool hasImage = postData['imageUrl'] != null &&
        postData['imageUrl'].toString().isNotEmpty;

    return Container(
      // REQUIREMENT 2: Remove fixed height.
      // relying on EdgeInsets and Column to define size.
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(196, 250, 249, 249),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes minimum space needed
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return UserProfileScreen(
                  userEmail: postData['email'],
                  username: postData['username'],
                  receiverImageUrl: postData['profile'],
                );
              }));
            },
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            leading: Container(
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueGrey.shade200, width: 1.5),
              ),
              child: Image.network(
                postData['profile'] ?? '', // Add null safety
                height: 45, width: 45, fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Icon(Icons.person),
              ),
            ),
            title: Text(
              usernameText(postData['username'].toString()),
              style: const TextStyle(
                color: Color.fromARGB(255, 21, 45, 81),
                fontWeight: FontWeight.w600,
                fontFamily: 'poppins',
                fontSize: 16,
              ),
            ),
            subtitle: Row(
              children: [
                Flexible(
                  child: Text(
                    postData["profession"] ?? "No Role",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12, color: Color.fromARGB(255, 90, 81, 81)),
                  ),
                ),
                const SizedBox(width: 5),
                const Text("•", style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 5),
                Text(
                  timeAgoFromString(postData['timeStamp']).toString(),
                  style: const TextStyle(
                    color: Color.fromARGB(255, 21, 45, 81),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              onPressed: () {/* print("options"); */},
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  maxLines: isExpanded ? null : 3,
                  overflow:
                      isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 3, 16, 35),
                    fontFamily: 'roboto',
                    fontSize: 15,
                    height: 1.4, // Better readability
                  ),
                ),
                if (content.length > 100)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        isExpanded ? "Show less" : "Read more",
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (hasImage)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return FullScreenImage(
                    imageFile: postData['imageUrl'],
                    tag: "postImage${widget.index}",
                  );
                }));
              },
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 8),
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(
                  color: Colors.grey, // placeholder color
                ),
                child: Image.network(
                  postData['imageUrl'],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                        child: CircularProgressIndicator(
                            color: Colors.blue.shade900));
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.error)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    userLiked ? Icons.favorite : Icons.favorite_border,
                    color: userLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    Map<String, dynamic>? userInfo =
                        await fetchCurrentUserInfo();
                    likePost(widget.docId, userInfo!['email']);
                  },
                ),
                Text('$likeCount',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(width: 15),
                IconButton(
                  onPressed: () async {
                    Map<String, dynamic>? userInfo =
                        await fetchCurrentUserInfo();
                    showCommentsBottomSheet(
                      context,
                      widget.docId,
                      userInfo: {
                        'username': userInfo!['username'],
                        'profileImage': userInfo['profilePic'],
                      },
                    );
                  },
                  icon: const FaIcon(FontAwesomeIcons.comment,
                      size: 20, color: Colors.grey),
                ),
                Text('$commentCount',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
                const SizedBox(width: 15),
                IconButton(
                  onPressed: () {
                    // share logic here
                  },
                  icon: const FaIcon(FontAwesomeIcons.share,
                      size: 20, color: Colors.grey),
                ),
                const Text(
                  '1212',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                // Inside your PostCard or Widget build method

                IconButton(
                  tooltip: "Summarize post",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AiSummaryScreen(
                            postContent: content,
                            imageUrl: hasImage ? postData['imageUrl'] : null,
                          );
                        },
                      ),
                    );
                  },
                  icon: Image.asset(
                    "assets/images/modelicon.png",
                    width: 26,
                    height: 26,
                    opacity: const AlwaysStoppedAnimation(0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
