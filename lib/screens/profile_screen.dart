import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/profile_post.dart';
import 'package:socialapp/widget/profile_summery.dart';
import "./../helpers/helper_functions.dart";

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  User? loggedUser = FirebaseAuth.instance.currentUser;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // 2 tabs: Posts & Favorites
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> getUserData() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentSnapshot doc =
        await db.collection("users").doc(loggedUser?.email).get();
    if (doc.exists) {
      return doc.data() as Map<String, dynamic>;
    } else {
      return null;
    }
  }

  void handleSignOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text("test Bar"),
        actions: [
          IconButton(
            onPressed: handleSignOut,
            icon: FaIcon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 55,
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>?>(
              future: getUserData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                } else if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data!;
                  return Column(
                    children: [
                      Column(
                        children: [
                          Container(
                            clipBehavior: Clip.hardEdge,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              // border: Border.all(
                              //   color:
                              //       Colors.blue.shade800.withOpacity(0.7),
                              //   width: 4,
                              // ),
                            ),
                            child: Image.network(
                              data["profilePic"],
                              fit: BoxFit.cover,
                              height: 140,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "\@" + data['username'],
                            style: const TextStyle(
                              fontSize: 37,
                              fontFamily: 'poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data['email'],
                            style: const TextStyle(fontFamily: 'poppins'),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.blue.shade100,
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromARGB(255, 23, 40, 53),
                              offset: Offset(0.2, 0.1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ProfileSummery(title: "Posts", amount: 12),
                            ProfileSummery(title: "Likes", amount: 23),
                            ProfileSummery(title: "Followers", amount: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // TabBar Section (Posts and Favorites)
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        tabs: const [
                          Tab(
                            icon: Icon(
                              Icons.post_add,
                              size: 30,
                            ),
                          ),
                          Tab(
                            icon: Icon(
                              Icons.favorite_border_outlined,
                              size: 30,
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        // TabBarView containing grid views for Posts and Favorites
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Posts Tab Content
                            PostGridView(),
                            // Favorites Tab Content
                            FavoriteGridView(),
                          ],
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Text("not working....");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Dummy PostGridView Widget (You can replace this with real video widgets)
class PostGridView extends StatelessWidget {
  User? u = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where('email', isEqualTo: u!.email.toString())
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              snapshot.error.toString(),
            ),
          );
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              "No Post Available",
              style: TextStyle(
                  color: Colors.blue.shade900, fontWeight: FontWeight.bold),
            ),
          );
        } else if (snapshot.hasData) {
          List<DocumentSnapshot> posts = snapshot.data!.docs;

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 1, // 3 columns for posts
              childAspectRatio: 9 / 5, // Aspect ratio for posts
            ),
            itemCount: posts.length, // Number of posts
            itemBuilder: (context, index) {
              Map<String, dynamic> postData =
                  posts[index].data() as Map<String, dynamic>;
              return Container(
                clipBehavior: Clip.hardEdge,
                height: 100,
                margin: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 246, 225, 164),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    if (postData['imageUrl'] != null)
                      Image.network(
                        postData["imageUrl"],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    if (postData['imageUrl'] == null)
                      Center(
                        child: Text(
                          postData['content'],
                        ),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: Container(
                          padding: EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ProfileMetaData(
                                  icon: Icons.favorite_border, content: '2k'),
                              ProfileMetaData(icon: Icons.share, content: '55'),
                              ProfileMetaData(
                                  icon: Icons.message_outlined, content: '25k'),
                            ],
                          )),
                    )
                  ],
                ),
                // child: Image.network(
                //   imageUrl[index],
                //   fit: BoxFit.cover,
                //   width: double.infinity,
                // ),
              );
            },
          );
        }
        return const Center(
          child: Text("Something went wrong!!"),
        );
      },
    );
  }
}

// Dummy FavoriteGridView Widget (You can replace this with real video widgets)
class FavoriteGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 columns for favorites
        childAspectRatio: 9 / 16, // Aspect ratio for favorites
      ),
      itemCount: 10, // Number of favorites
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.all(4.0),
          color: Colors.greenAccent,
          child: Center(
            child: Text('Favorite $index',
                style: const TextStyle(color: Colors.white)),
          ),
        );
      },
    );
  }
}
