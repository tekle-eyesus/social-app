import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/comment_item.dart';
import 'package:socialapp/widget/comment_shimmer.dart';

void showCommentsBottomSheet(
    BuildContext context, String postId, String currentUsername) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75, // Starts at 75% height
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, controller) {
          return CommentSheetContent(
            scrollController: controller,
            postId: postId,
            currentUsername: currentUsername,
          );
        },
      );
    },
  );
}

class CommentSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final String postId;
  final String currentUsername;

  const CommentSheetContent({
    Key? key,
    required this.scrollController,
    required this.postId,
    required this.currentUsername,
  }) : super(key: key);

  @override
  State<CommentSheetContent> createState() => _CommentSheetContentState();
}

class _CommentSheetContentState extends State<CommentSheetContent> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border:
                Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Text(
                "Comments",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Positioned(
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),

        // --- Comments List ---
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('posts')
                .doc(widget.postId)
                .collection('comments')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CommentShimmer();
              }

              final comments = snapshot.data?.docs ?? [];

              if (comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 60, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        "No comments yet",
                        style: TextStyle(
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "Be the first to start the conversation.",
                        style: TextStyle(
                            color: Colors.grey.shade400, fontSize: 12),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                controller: widget.scrollController,
                itemCount: comments.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemBuilder: (context, index) {
                  final comment =
                      comments[index].data() as Map<String, dynamic>;
// Mock logic to determine if this comment has replies (for demo purposes)
                  final bool mockHasReplies = index % 3 == 0 && index != 0;

                  return CommentItem(
                      commentData: comment, hasReplies: mockHasReplies);
                },
              );
            },
          ),
        ),

        Container(
          padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 10,
              bottom: bottomPadding + 10 // Adjust for keyboard
              ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                offset: const Offset(0, -2),
                blurRadius: 5,
              )
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey,
                child: Icon(Icons.person, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),

              // Input Field
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add comment...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Send Button
              _isPosting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : GestureDetector(
                      onTap: _postComment,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward,
                            color: Colors.blue, size: 20),
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      // Fetch user data (kept your original logic)
      final currentUserEmail =
          FirebaseAuth.instance.currentUser!.email.toString();
      Map<String, dynamic>? userData =
          await fetchUserDataById(currentUserEmail);

      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .add({
        'userId': currentUserEmail,
        'username': widget.currentUsername,
        'profilePic': userData!['profilePic'],
        'commentText': _commentController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
        'likes': [], // Initialize empty likes
      });

      // Update count
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .update({'commentsCount': FieldValue.increment(1)});

      _commentController.clear();
      // Dismiss keyboard
      FocusScope.of(context).unfocus();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }
}
