import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/post_card.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                        color: Colors.red.shade700,
                        strokeWidth: 2,
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
                        // Get the data
                        Map<String, dynamic> postData =
                            posts[index].data() as Map<String, dynamic>;
                        String docId = posts[index].id;

                        return PostItem(
                          postData: postData,
                          docId: docId,
                          index: index,
                        );
                      }),
                    );
                  } else {
                    return Text("no data exist");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
