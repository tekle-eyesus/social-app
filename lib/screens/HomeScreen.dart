import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/custom_drawer.dart';
import 'package:socialapp/widget/custom_textfield.dart';
import 'package:socialapp/widget/post_btn.dart';

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

      await db.collection("posts").doc(loggedUser!.email).set({
        "content": postMessageController.text,
        "email": loggedUser.email,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: MyDrawer(),
      appBar: AppBar(
        foregroundColor: AppColors.primaryText,

        centerTitle: true,
        // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "R I N G",
          style: TextStyle(
              color: Colors.blue,
              fontFamily: 'sofa',
              fontWeight: FontWeight.w800),
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PostButton(
                  onTap: () {},
                  icon: Icons.image_sharp,
                ),
                Container(
                  width: 290,
                  margin: EdgeInsets.all(10),
                  padding: EdgeInsets.only(left: 7),
                  decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: TextField(
                    controller: postMessageController,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey.shade700),
                        border: InputBorder.none,
                        hintText: "write some thing..."),
                  ),
                ),
                PostButton(
                  onTap: handlePost,
                  icon: Icons.mark_chat_read_rounded,
                ),
              ],
            ),
          ),
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
                          margin: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              color: AppColors.primaryVariant,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(left: 5, right: 5),
                                    child: Icon(
                                      Icons.circle_notifications_sharp,
                                      size: 45,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        postData['email'].toString(),
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 21, 45, 81),
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'poppins',
                                            fontSize: 18),
                                      ),
                                      Text(
                                        postData['timeStamp'].toString(),
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 21, 45, 81),
                                            fontWeight: FontWeight.w500),
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
                                  child: Image.network(
                                "https://static1.colliderimages.com/wordpress/wp-content/uploads/2023/06/cersei-lannister-jon-snow-and-daenerys-targaryen-from-game-of-thrones.jpg",
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
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.thumb_up,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.comment,
                                      )),
                                  IconButton(
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.share_sharp,
                                      )),
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
