import 'package:flutter/material.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/full_screen_image.dart';

class MessageBubble extends StatelessWidget {
  final Map<String, dynamic>? message;
  final bool isSentByMe;
  const MessageBubble(
      {super.key, required this.message, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    final String type = message!['type'] ?? 'text';
    final String text = message!['text'] ?? '';
    final String imageUrl = message!['imageUrl'] ?? '';
    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.black : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSentByMe
                ? const Radius.circular(16)
                : const Radius.circular(2),
            bottomRight: isSentByMe
                ? const Radius.circular(2)
                : const Radius.circular(16),
          ),
          // ... shadow logic ...
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // --- DISPLAY LOGIC ---
            if (type == 'image')
              GestureDetector(
                onTap: () {
                  // Optional: Open full screen image
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FullScreenImage(
                              imageFile: imageUrl, tag: imageUrl)));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: 200,
                        color: Colors.grey.shade800,
                        child: const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                      );
                    },
                  ),
                ),
              )
            else
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isSentByMe ? Colors.white : Colors.black87,
                ),
              ),

            const SizedBox(height: 4),

            // --- TIMESTAMP ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTimestamp(message!['timestamp']),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSentByMe ? Colors.white70 : Colors.black45,
                  ),
                ),
                if (isSentByMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 14, color: Colors.white70),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
