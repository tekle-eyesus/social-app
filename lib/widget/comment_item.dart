import 'package:flutter/material.dart';
import 'package:socialapp/helpers/helper_functions.dart';

class CommentItem extends StatelessWidget {
  final Map<String, dynamic> commentData;
  final bool hasReplies;

  const CommentItem({
    Key? key,
    required this.commentData,
    this.hasReplies = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: NetworkImage(commentData['profilePic']),
            onBackgroundImageError: (_, __) => const Icon(Icons.person),
          ),
          const SizedBox(width: 12),

          // 2. Middle Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username
                Text(
                  commentData['username'] ?? 'User',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),

                // Comment Text
                Text(
                  commentData['commentText'] ?? '',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 6),

                // Metadata (Time • Reply)
                Row(
                  children: [
                    Text(
                      timeAgoFromString(commentData['timestamp'].toString()),
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                    const SizedBox(width: 15),
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement reply logic
                        print("Reply tapped");
                      },
                      child: Text(
                        "Reply",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600),
                      ),
                    ),
                  ],
                ),

                // 3. Threaded Replies UI (Visual Only)
                if (hasReplies)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 1,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "View 3 replies", // Static number for UI demo
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        Icon(Icons.keyboard_arrow_down,
                            size: 16, color: Colors.grey.shade500)
                      ],
                    ),
                  )
              ],
            ),
          ),

          // 4. Like Button (Heart)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: Column(
              children: [
                const Icon(Icons.favorite_border, size: 18, color: Colors.grey),
                const SizedBox(height: 2),
                Text(
                  "0", // Placeholder for like count
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
