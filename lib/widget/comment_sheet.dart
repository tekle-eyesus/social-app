import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:socialapp/helpers/helper_functions.dart';

Future<String> getImageUrl(String userId) async {
  Map<String, dynamic>? userData = await fetchUserDataById(userId);
  return "";
}

void showCommentsBottomSheet(
    BuildContext context, String postId, String currentUsername) {
  showModalBottomSheet(
    elevation: 0,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      TextEditingController commentController = TextEditingController();

      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.7, // Set max height
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Comments',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Comments List
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .collection('comments')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    final comments = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment =
                            comments[index].data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(
                            comment['username'],
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          leading: Container(
                            clipBehavior: Clip.hardEdge,
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Image.network(
                              comment['profilePic'],
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                          ),
                          subtitle: Text(comment['commentText']),
                          trailing: Text(
                            timeAgoFromString(comment['timestamp'].toString()),
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Comment Input Field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration: InputDecoration(
                          hintText: 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        if (commentController.text.trim().isNotEmpty) {
                          Map<String, dynamic>? userData =
                              await fetchUserDataById(FirebaseAuth
                                  .instance.currentUser!.email
                                  .toString());
                          await FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .collection('comments')
                              .add({
                            'userId': FirebaseAuth.instance.currentUser!.email,
                            'username': currentUsername,
                            'profilePic': userData!['profilePic'],
                            'commentText': commentController.text.trim(),
                            'timestamp': DateTime.now().toIso8601String(),
                          });

                          // Update comments count in the post document
                          await FirebaseFirestore.instance
                              .collection('posts')
                              .doc(postId)
                              .update({
                            'commentsCount': FieldValue.increment(1),
                          });

                          commentController.clear();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
