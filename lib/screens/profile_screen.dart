import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/widget/full_screen_image.dart';
import 'package:socialapp/widget/post_card.dart';
import 'package:socialapp/widget/post_shimmer.dart';

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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void handleSignOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryText = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: Text(
          "Profile",
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: handleSignOut,
            icon: FaIcon(
              Icons.logout_rounded,
              color: Colors.red.shade400,
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchCurrentUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            Map<String, dynamic> data = snapshot.data!;
            return Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Profile Picture with Shadow/Border
                      Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.shade200,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              )
                            ]),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: NetworkImage(data["profilePic"]),
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Name
                      Text(
                        data['username'],
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: 0.5,
                        ),
                      ),

                      // Email / Handle
                      Text(
                        data['email'],
                        style: TextStyle(
                            fontSize: 14,
                            color: secondaryText,
                            fontWeight: FontWeight.w500),
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStatItem("Likes", "13", isDark),
                          Container(
                              height: 25,
                              width: 1,
                              color: Colors.grey.shade300,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 25)),
                          _buildStatItem("Rating", "4.8", isDark),
                        ],
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark
                                    ? Colors.grey.shade800
                                    : Colors.black,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("Edit Profile",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textColor,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text("Share",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --- TAB BAR ---
                Container(
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: Colors.grey.shade200))),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: textColor,
                    indicatorWeight: 2,
                    labelColor: textColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: const [
                      Tab(
                          icon: Icon(Icons.grid_on_rounded,
                              size: 26)), // Instagram style Grid icon
                      Tab(icon: Icon(Icons.favorite_border_rounded, size: 26)),
                    ],
                  ),
                ),

                // --- CONTENT ---
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      PostGridView(),
                      FavoriteGridView(),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text("Something went wrong"));
          }
        },
      ),
    );
  }

  // Helper widget for stats to keep code clean
  Widget _buildStatItem(String label, String count, bool isDark) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class PostGridView extends StatelessWidget {
  final User? u = FirebaseAuth.instance.currentUser;

  PostGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("posts")
          .where(
            'email',
            isEqualTo: u!.email.toString(),
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PostShimmerLoading();
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(FontAwesomeIcons.camera,
                    size: 50, color: Colors.grey.shade300),
                const SizedBox(height: 10),
                Text("No Posts Yet",
                    style: TextStyle(color: Colors.grey.shade500)),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          List<DocumentSnapshot> posts = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.only(top: 10, bottom: 20),
            itemCount: posts.length,
            separatorBuilder: (ctx, i) => const Divider(
                height: 30,
                thickness: 8,
                color: Color(0xFFF5F5F5)), // Divider between posts
            itemBuilder: (context, index) {
              Map<String, dynamic> postData =
                  posts[index].data() as Map<String, dynamic>;
              String docId = posts[index].id;
              return PostItem(
                postData: postData,
                docId: docId,
                index: index,
              );
            },
          );
        }
        return const Center(child: Text("Something went wrong!!"));
      },
    );
  }
}

class FavoriteGridView extends StatelessWidget {
  const FavoriteGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          color: Colors.grey.shade300,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Placeholder image logic
              InkWell(
                onTap: () {
                  // full screen image view ( for now)
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return FullScreenImage(
                        tag: "$index",
                        imageFile: "https://picsum.photos/500?random=$index",
                      );
                    }),
                  );
                },
                // random images from picsum for demo purposes
                child: Image.network(
                  "https://picsum.photos/200?random=$index",
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.image, color: Colors.white),
                  ),
                ),
              ),
              // Overlay icon
              const Align(
                alignment: Alignment.center,
                child: Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 30),
              )
            ],
          ),
        );
      },
    );
  }
}
