import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connect_guard/connect_guard.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:socialapp/helpers/snackbar_helper.dart';
import 'package:socialapp/screens/search_screen.dart';
import 'package:socialapp/theme/app_colors.dart';
import 'package:socialapp/widget/offline_page.dart';
import 'package:socialapp/widget/post_card.dart';
import 'package:socialapp/widget/post_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController postMessageController = TextEditingController();
  Map<String, dynamic>? currentUserData;
  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() async {
    Map<String, dynamic>? userData = await fetchCurrentUserInfo();
    setState(() {
      currentUserData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ConnectGuard(
        builder: (context) {
          return NestedScrollView(
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
                  leading: Row(
                    children: [
                      const SizedBox(
                        width: 6,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(
                          currentUserData?['profilePic'] ??
                              'https://www.pngall.com/wp-content/uploads/5/Profile-PNG-High-Quality-Image.png',
                        ),
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
                        FontAwesomeIcons.magnifyingGlass,
                        size: 22,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SearchScreen()),
                        );
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
                        return const PostShimmerLoading();
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
          );
        },
        onConnectivityChanged: (isOnline) {
          isOnline
              ? CustomSnackBar.showSuccess(context, "Back Online!")
              : CustomSnackBar.showError(context, "Lost Connection!");
        },
        offlineBuilder: (context) {
          return const OfflinePage();
        },
      ),
    );
  }
}
