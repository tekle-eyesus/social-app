import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/screens/user_profile_screen.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/comment_sheet.dart';

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
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              snap: true,
              centerTitle: true,
              leadingWidth: 46,
              foregroundColor: AppColors.primaryText,
              backgroundColor: AppColors.surface,
              // elevation: 0,
              leading: const Row(
                children: [
                  SizedBox(
                    width: 6,
                  ),
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSUyllrW-u-01_B8qMki4ybHzbhuBWhUq3pMA&s"),
                  ),
                ],
              ),
              title: const Text(
                "Feed",
                style: TextStyle(
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 21, 45, 81)),
              ),
              actions: [
                IconButton(
                  icon: const FaIcon(
                    FontAwesomeIcons.search,
                    size: 25,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    print("search logic here");
                  },
                ),
                const SizedBox(
                  width: 6,
                ),
              ],
            ),
          ];
        },
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
                        padding: const EdgeInsets.only(top: 8, bottom: 67),
                        itemCount: posts.length,
                        itemBuilder: ((context, index) {
                          Map<String, dynamic> postData =
                              posts[index].data() as Map<String, dynamic>;

                          final likeCount = postData['likesCount'] ?? 0;
                          final commentCount = postData['commentsCount'] ?? 0;
                          final likedBy = List.from(postData['likedBy'] ?? []);
                          final userLiked = likedBy.contains(
                              FirebaseAuth.instance.currentUser!.email);
                          return Container(
                            height: (postData['imageUrl'] != null) ? 377 : 180,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            padding: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                                color: Color.fromARGB(196, 250, 249, 249),
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return UserProfileScreen(
                                        userEmail: postData['email'],
                                        username: postData['username'],
                                        receiverImageUrl: postData['profile'],
                                      );
                                    }));
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  leading: Container(
                                    clipBehavior: Clip.hardEdge,
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Image.network(
                                      postData['profile'],
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    usernameText(
                                        postData['username'].toString()),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 21, 45, 81),
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'poppins',
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        postData["profession"] != null
                                            ? postData["profession"].toString()
                                            : "No Role",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Color.fromARGB(
                                                255, 90, 81, 81)),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        "•",
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        timeAgoFromString(postData['timeStamp'])
                                            .toString(),
                                        style: const TextStyle(
                                          color:
                                              Color.fromARGB(255, 21, 45, 81),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons
                                          .more_vert, // Commonly used icon for options menus
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      // Define action for the menu, if any
                                    },
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 20),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    postData['content'].toString(),
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 3, 16, 35),
                                      fontFamily: 'roboto',
                                    ),
                                  ),
                                ),
                                if (postData["imageUrl"] != null)
                                  Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 10),
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
                                          return Center(
                                              child: Icon(Icons.error));
                                        },
                                      )),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        userLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: userLiked
                                            ? Colors.red
                                            : Colors.grey,
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
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 3),
                                      decoration: const BoxDecoration(
                                          color: Color.fromARGB(97, 0, 0, 0),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(1),
                                              bottomLeft: Radius.circular(7),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(7))),
                                      child: Text(
                                        '$likeCount likes',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
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
                                      icon: const FaIcon(
                                        FontAwesomeIcons.comment,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2, horizontal: 3),
                                      decoration: const BoxDecoration(
                                          color: Color.fromARGB(97, 0, 0, 0),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(1),
                                              bottomLeft: Radius.circular(7),
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(7))),
                                      child: Text(
                                        '$commentCount comments',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
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
      ),
      backgroundColor: Colors.blue.shade100,
    );
  }
}
