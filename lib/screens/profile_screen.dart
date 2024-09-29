import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: Column(
        children: [
          const SizedBox(
            height: 30,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.blue.shade400,
                  ),
                  child: const Icon(Icons.arrow_back_ios_outlined),
                ),
              ),
            ],
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
                      Image.network(
                        "https://img.freepik.com/free-photo/androgynous-avatar-non-binary-queer-person_23-2151100270.jpg?size=338&ext=jpg&ga=GA1.1.1819120589.1727481600&semt=ais_hybrid",
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                      Text(
                        data['username'],
                        style: const TextStyle(
                          fontSize: 25,
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        data['email'],
                        style: const TextStyle(fontFamily: 'poppins'),
                      ),
                      const SizedBox(height: 20),

                      // TabBar Section (Posts and Favorites)
                      TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.black,
                        labelColor: Colors.black,
                        tabs: const [
                          Tab(text: "Posts"),
                          Tab(text: "Favorites"),
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
  List<String> imageUrl = [
    "https://t4.ftcdn.net/jpg/03/69/19/81/360_F_369198116_K0sFy2gRTo1lmIf5jVGeQmaIEibjC3NN.jpg",
    "https://media.istockphoto.com/id/1435220822/photo/african-american-software-developer.jpg?s=612x612&w=0&k=20&c=JESGRQ2xqRH9ZcJzvZBHZIZKVY8MDejBSOfxeM-i5e4=",
    "https://images.ctfassets.net/19dvw6heztyg/1Kh1hVqbZSsSL4HM5TrJX3/6e19c050bd007e99f915e5034b87ebb6/seo-earn-more-as-developer?w=1200&h=600&fit=fill&q=75&fm=jpg",
    "https://thumbor.forbes.com/thumbor/fit-in/900x510/https://www.forbes.com/advisor/wp-content/uploads/2022/08/web_developer.jpeg.jpg",
    "https://img.freepik.com/free-vector/hand-drawn-web-developers_23-2148819604.jpg"
  ];
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1, // 3 columns for posts
        childAspectRatio: 9 / 5, // Aspect ratio for posts
      ),
      itemCount: imageUrl.length, // Number of posts
      itemBuilder: (context, index) {
        return Container(
          height: 100,
          margin: const EdgeInsets.all(4.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.blueAccent,
          ),
          child: Image.network(
            imageUrl[index],
            fit: BoxFit.cover,
            width: double.infinity,
          ),
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
