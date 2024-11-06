import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/comment_sheet.dart';
import 'package:socialapp/widget/post_stats.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController postMessageController = TextEditingController();
//to handle user posting
  void handlePost() async {
    User? loggedUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore db = FirebaseFirestore.instance;
    if (postMessageController.text.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor,
              ),
            );
          });
//what about
      await db.collection("posts").doc().set({
        "content": postMessageController.text,
        "email": loggedUser!.email,
        "timeStamp": DateTime.now().toIso8601String(),
      });
      Navigator.pop(context);
      postMessageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        width: 200,
        duration: const Duration(seconds: 1),
        content: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 70),
          height: 44,
          decoration: BoxDecoration(
              color: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(12)),
          child: Text(
            "POSTED !!!",
            style: TextStyle(
                color: Colors.deepPurple.shade600, fontFamily: 'poppins'),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        width: 200,
        duration: Duration(seconds: 1),
        content: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 70),
          height: 44,
          decoration: BoxDecoration(
              color: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(12)),
          child: Text(
            "Say something!!",
            style: TextStyle(
                color: Colors.deepPurple.shade600, fontFamily: 'poppins'),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ));
    }
  }

  // LIKE IMPLEMENTATION

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

  String usernameText(String username) {
    return username[0].toUpperCase() + username.substring(1);
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    // Fetch user information using the helper function
    Map<String, dynamic>? userInfo = await fetchCurrentUserInfo();

    if (userInfo != null) {
      // If user info is found, return it
      return userInfo;
    } else {
      // Return null if user is not found or not logged in
      print("User not found or not logged in.");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 65,
        leadingWidth: 45,
        foregroundColor: AppColors.primaryText,
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.only(left: 10),
          child: Image.asset(
            "assets/images/header-logo.png",
            height: 55,
          ),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.blue.shade200,
            borderRadius: BorderRadius.circular(5),
          ),
          child: const TextField(
            decoration: InputDecoration(
              hintText: "Search",
              prefixIcon: Padding(
                padding: EdgeInsets.all(8.0),
                child: FaIcon(
                  FontAwesomeIcons.search,
                  size: 20,
                  color: Colors.grey,
                ),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        actions: [
          IconButton(
              // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
              icon: const FaIcon(
                FontAwesomeIcons.message,
                size: 25,
                color: Colors.blue,
              ),
              onPressed: () {
                print("Pressed");
              }),
          const SizedBox(
            width: 6,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("posts")
                  .orderBy('timeStamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.secondaryColor,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      "No Post Available",
                      style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.bold),
                    ),
                  );
                } else if (snapshot.hasData) {
                  List<DocumentSnapshot> posts = snapshot.data!.docs;
                  return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: ((context, index) {
                        Map<String, dynamic> postData =
                            posts[index].data() as Map<String, dynamic>;
                        print(postData);
////////////////////////////////////////////////
                        final post = snapshot.data!;
                        final likeCount = postData['likesCount'] ?? 0;
                        final commentCount = postData['commentsCount'] ?? 0;
                        final likedBy = List.from(postData['likedBy'] ?? []);
                        final userLiked = likedBy
                            .contains(FirebaseAuth.instance.currentUser!.email);
                        return Container(
                          height: (postData['imageUrl'] != null) ? 360 : 156,
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(97, 233, 184, 184),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    clipBehavior: Clip.hardEdge,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Image.network(
                                      postData['profile'],
                                      height: 50,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        usernameText(
                                            postData['username'].toString()),
                                        style: const TextStyle(
                                            color:
                                                Color.fromARGB(255, 21, 45, 81),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'poppins',
                                            fontSize: 22),
                                      ),
                                      Row(
                                        children: [
                                          Text((postData["profession"] != null
                                              ? postData["profession"]
                                                  .toString()
                                              : "No Role")),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          const Text(
                                            "•",
                                            style: TextStyle(
                                              // fontWeight: FontWeight.bold,
                                              color: Colors.grey,
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 8,
                                          ),
                                          Text(
                                            timeAgoFromString(
                                                    postData['timeStamp'])
                                                .toString(),
                                            style: const TextStyle(
                                                color: Color.fromARGB(
                                                    255, 21, 45, 81),
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.all(10),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  postData['content'].toString(),
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 3, 16, 35),
                                    fontFamily: 'poppins',
                                  ),
                                ),
                              ),
                              if (postData["imageUrl"] != null)
                                Container(
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    height: 200,
                                    child: Image.network(
                                      postData['imageUrl'],
                                      width: double.infinity,
                                      fit: BoxFit
                                          .cover, // Fill the grid tile with the image
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                          color: Colors.blue.shade900,
                                        )));
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(child: Icon(Icons.error));
                                      },
                                    )),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      userLiked
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          userLiked ? Colors.red : Colors.grey,
                                    ),
                                    onPressed: () async {
                                      Map<String, dynamic>? userInfo =
                                          await getUserInfo();
                                      likePost(
                                          snapshot.data!.docs[index].id,
                                          userInfo![
                                              'email']); // Pass current post ID and user ID.
                                    },
                                  ),
                                  Text('$likeCount likes'),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      Map<String, dynamic>? userInfo =
                                          await getUserInfo();
                                      // print(userInfo!['username']);
                                      showCommentsBottomSheet(
                                          context,
                                          snapshot.data!.docs[index].id,
                                          userInfo!['username'].toString());
                                    },
                                    icon: FaIcon(
                                      FontAwesomeIcons.comment,
                                    ),
                                  ),
                                  Text('$commentCount comments')
                                ],
                              )
                            ],
                          ),
                        );
                      }));
                } else {
                  return Text("no data exist");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
