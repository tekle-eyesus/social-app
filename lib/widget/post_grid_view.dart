import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/widget/post_card.dart';
import 'package:socialapp/widget/post_shimmer.dart';

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
