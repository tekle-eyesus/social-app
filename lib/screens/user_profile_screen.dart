import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/screens/chat_screen.dart';
import 'package:socialapp/widget/comment_sheet.dart';

class UserProfileScreen extends StatefulWidget {
  final String userEmail;
  const UserProfileScreen({super.key, required this.userEmail});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Future<Map<String, dynamic>?> getUserInfo() async {
    // Fetch user information using the helper function
    Map<String, dynamic>? userInfo = await fetchCurrentUserInfo();
    if (userInfo != null) {
      return userInfo;
    } else {
      print("User not found or not logged in.");
      return null;
    }
  }

  String usernameText(String username) {
    return username[0].toUpperCase() + username.substring(1);
  }

  Future<void> likePost(String postId, String userId) async {
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    DocumentSnapshot postSnapshot = await postRef.get();
    List likedBy = postSnapshot['likedBy'] ?? [];
    if (likedBy.contains(userId)) {
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade300,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.blue.shade300,
        actions: [
          IconButton(
            onPressed: () {
              // chat screen
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return const ChatScreen();
              }));
            },
            icon: const FaIcon(
              FontAwesomeIcons.message,
            ),
          ),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: getUserInfo(),
          builder: (context, userInfoSnapshot) {
            if (userInfoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(
                color: Color.fromARGB(255, 14, 57, 92),
              ));
            }
            if (!userInfoSnapshot.hasData) {
              return const Center(child: Text("User data could not be loaded"));
            }

            // Metadata section
            var userInfo = userInfoSnapshot.data;
            return StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('email', isEqualTo: widget.userEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                } else if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No Posts for this user!"));
                } else if (snapshot.hasData) {
                  List<DocumentSnapshot> posts = snapshot.data!.docs;

                  // Display metadata and posts together
                  return ListView(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    children: [
                      // Metadata section
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 17, vertical: 6),
                            clipBehavior: Clip.hardEdge,
                            width: 137,
                            height: 190,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Image.network(
                              userInfo?['profile'] ??
                                  "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS-YIGV8GTRHiW_KACLMhhi9fEq2T5BDQcEyA&s",
                              fit: BoxFit.cover,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 6, right: 2),
                            height: 200,
                            width: 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  horizontalTitleGap: 0,
                                  contentPadding: const EdgeInsets.all(0),
                                  title: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize
                                        .min, // Minimizes the vertical space
                                    children: [
                                      Text(
                                        usernameText(
                                            userInfo?['username'] ?? ""),
                                        style: const TextStyle(
                                          fontFamily: 'teko',
                                          fontSize: 40,
                                        ),
                                      ),
                                      // / Adjust this value to control the spacing
                                      Text(
                                        userInfo?['profession'] ??
                                            "Profession not set",
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontFamily: 'roboto',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 250, 238, 200),
                                          borderRadius: BorderRadius.circular(
                                            5,
                                          )),
                                      child: const Icon(Icons.email,
                                          color: Colors.amber, size: 35),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 250, 210, 200),
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          )),
                                      child: const Icon(Icons.call,
                                          color: Colors.red, size: 35),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(
                                              255, 213, 200, 250),
                                          borderRadius: BorderRadius.circular(
                                            7,
                                          )),
                                      child: const Icon(Icons.video_call,
                                          color: Colors.black, size: 35),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // About Section
                      const Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 5, top: 17),
                        child: Text(
                          "About",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(userInfo?['about'] ??
                            "Flutter socila App UI designed by tekle. Connect with them on linkedin; the global community for designers and creative professionals."),
                      ),
                      // Posts Section
                      const Padding(
                        padding: EdgeInsets.only(left: 15, bottom: 9, top: 17),
                        child: Text(
                          "Posts",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      ...posts.map((post) {
                        Map<String, dynamic> postData =
                            post.data() as Map<String, dynamic>;
                        final likeCount = postData['likesCount'] ?? 0;
                        final commentCount = postData['commentsCount'] ?? 0;
                        final likedBy = List.from(postData['likedBy'] ?? []);
                        final userLiked = likedBy
                            .contains(FirebaseAuth.instance.currentUser!.email);

                        return Container(
                          height: postData['imageUrl'] != null ? 377 : 180,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(196, 250, 249, 249),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                leading: Container(
                                  clipBehavior: Clip.hardEdge,
                                  margin:
                                      const EdgeInsets.only(left: 5, right: 5),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Image.network(
                                    postData['profile'],
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  usernameText(postData['username'].toString()),
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 24, 50, 90),
                                    fontFamily: "roboto",
                                    fontWeight: FontWeight.w600,
                                    fontSize: 17,
                                  ),
                                ),
                                subtitle: Row(
                                  children: [
                                    // Text(postData["profession"] ?? "No Role"),
                                    // const Text(" • "),
                                    Text(timeAgoFromString(
                                        postData['timeStamp'])),
                                  ],
                                ),
                                trailing: Icon(Icons.more_vert),
                              ),
                              // Post Content

                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18.0,
                                      vertical: 5,
                                    ),
                                    child: Text(postData['content'].toString()),
                                  ),
                                ],
                              ),

                              if (postData["imageUrl"] != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Image.network(
                                      postData['imageUrl'],
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              // Like and Comment
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                        userLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: userLiked
                                            ? Colors.red
                                            : Colors.grey),
                                    onPressed: () async {
                                      var userInfo = await getUserInfo();
                                      likePost(post.id, userInfo!['email']);
                                    },
                                  ),
                                  Text('$likeCount likes'),
                                  IconButton(
                                    icon: const Icon(FontAwesomeIcons.comment),
                                    onPressed: () async {
                                      var userInfo = await getUserInfo();
                                      showCommentsBottomSheet(context, post.id,
                                          userInfo!['username'].toString());
                                    },
                                  ),
                                  Text('$commentCount comments'),
                                ],
                              )
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }
                return const Center(child: Text("Something went wrong!"));
              },
            );
          },
        ),
      ),
    );
  }
}
