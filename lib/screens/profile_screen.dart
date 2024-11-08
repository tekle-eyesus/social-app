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
        backgroundColor: Colors.blue.shade100,
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
                        height: 5,
                      ),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.solidHeart,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "13",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 22,
                              fontFamily: 'teko',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "•",
                            style: TextStyle(
                              fontFamily: 'poppins',
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          FaIcon(
                            FontAwesomeIcons.solidStar,
                            color: Color.fromARGB(255, 190, 172, 1),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "100",
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 22,
                              fontFamily: 'teko',
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(73, 0, 0, 0),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "Edit Profile",
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(73, 0, 0, 0),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              "Share Profile",
                              style: TextStyle(
                                color: Colors.blue.shade100,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
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

          return ListView.builder(
            itemCount: posts.length, // Number of posts
            itemBuilder: (context, index) {
              Map<String, dynamic> postData =
                  posts[index].data() as Map<String, dynamic>;
              return Container(
                clipBehavior: Clip.hardEdge,
                // height: (postData['imageUrl'] != null) ? 50 : 100,

                margin: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  color: Color.fromARGB(69, 0, 3, 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    //content

                    if (postData['imageUrl'] != null)
                      Container(
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Image.network(
                          "https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885_640.jpg",
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          postData['content'],
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            // fontFamily: 'roboto',
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.favorite_border_outlined,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text(
                            postData['likesCount'].toString(),
                            style: TextStyle(
                              color: Colors.purple,
                              fontSize: 17,
                              fontFamily: 'teko',
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
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
