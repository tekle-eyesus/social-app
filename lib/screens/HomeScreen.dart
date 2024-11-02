import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/screens/post_screen.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/custom_drawer.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/post_btn.dart';
import 'package:socialapp/widget/post_stats.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

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
        duration: Duration(seconds: 1),
        content: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.only(bottom: 70),
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

  String timeAgoFromString(String timestampString) {
    try {
      // Parse the timestamp string to DateTime
      DateTime postDate = DateTime.parse(timestampString);
      Duration difference = DateTime.now().difference(postDate);

      if (difference.inSeconds < 60) {
        return "${difference.inSeconds}s ago";
      } else if (difference.inMinutes < 60) {
        return "${difference.inMinutes} min ago";
      } else if (difference.inHours < 24) {
        return "${difference.inHours} hr ago";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} days ago";
      } else if (difference.inDays < 30) {
        return "${(difference.inDays / 7).floor()} week(s) ago";
      } else if (difference.inDays < 365) {
        return "${(difference.inDays / 30).floor()} month(s) ago";
      } else {
        return "${(difference.inDays / 365).floor()} year(s) ago";
      }
    } catch (e) {
      // Handle any parsing errors or invalid timestamp format
      print("Error parsing timestamp: $e");
      return "Invalid date";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // drawer: const MyDrawer(),
      appBar: AppBar(
        foregroundColor: AppColors.primaryText,
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          "R I N G",
          style: TextStyle(
              color: Colors.blue,
              fontFamily: 'sofa',
              fontWeight: FontWeight.w800),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                return PostScreen();
              }));
            },
            child: Container(
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.shade500,
              ),
              child: Icon(
                Icons.add,
              ),
            ),
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
                        return Container(
                          height: 340,
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: Color.fromARGB(255, 251, 244, 244),
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    clipBehavior: Clip.hardEdge,
                                    margin: EdgeInsets.only(left: 5, right: 5),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        postData['username'].toString(),
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 21, 45, 81),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'poppins',
                                            fontSize: 22),
                                      ),
                                      Row(
                                        children: [
                                          Text("UI/UX designer"),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            timeAgoFromString(
                                                    postData['timeStamp'])
                                                .toString(),
                                            style: TextStyle(
                                                color: const Color.fromARGB(
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
                                      if (loadingProgress == null) return child;
                                      return Center(
                                          child: Center(
                                              child: CircularProgressIndicator(
                                        color: Colors.blue.shade900,
                                      )));
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(child: Icon(Icons.error));
                                    },
                                  )),
                              const Row(
                                children: [
                                  PostStats(
                                      icon: Icons.favorite_border,
                                      value: "123"),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  PostStats(icon: Icons.chat, value: "45"),
                                  SizedBox(
                                    width: 7,
                                  ),
                                  PostStats(
                                      icon: Icons.share_outlined, value: "12k"),
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
