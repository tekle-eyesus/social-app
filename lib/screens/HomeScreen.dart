import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/screens/post_screen.dart';
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

  List<String> imageUrl = [
    "https://t4.ftcdn.net/jpg/03/69/19/81/360_F_369198116_K0sFy2gRTo1lmIf5jVGeQmaIEibjC3NN.jpg",
    "https://media.istockphoto.com/id/1435220822/photo/african-american-software-developer.jpg?s=612x612&w=0&k=20&c=JESGRQ2xqRH9ZcJzvZBHZIZKVY8MDejBSOfxeM-i5e4=",
    "https://images.ctfassets.net/19dvw6heztyg/1Kh1hVqbZSsSL4HM5TrJX3/6e19c050bd007e99f915e5034b87ebb6/seo-earn-more-as-developer?w=1200&h=600&fit=fill&q=75&fm=jpg",
    "https://thumbor.forbes.com/thumbor/fit-in/900x510/https://www.forbes.com/advisor/wp-content/uploads/2022/08/web_developer.jpeg.jpg",
    "https://img.freepik.com/free-vector/hand-drawn-web-developers_23-2148819604.jpg",
    "https://t4.ftcdn.net/jpg/03/69/19/81/360_F_369198116_K0sFy2gRTo1lmIf5jVGeQmaIEibjC3NN.jpg"
  ];

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
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                      return PostScreen();
                    }));
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.blue.shade500,
                    ),
                    child: Icon(
                      Icons.image,
                    ),
                  ),
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
                                  height: 200,
                                  child: Image.network(
                                    imageUrl[index],
                                    width: double.infinity,
                                    fit: BoxFit
                                        .fill, // Fill the grid tile with the image
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
