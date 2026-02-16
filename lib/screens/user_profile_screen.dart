import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/screens/chat_screen.dart';

class UserProfileScreen extends StatefulWidget {
  final String userEmail;
  final String username;
  final String receiverImageUrl;
  const UserProfileScreen({
    super.key,
    required this.userEmail,
    required this.username,
    required this.receiverImageUrl,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // -- LOGIC: LIKE POST --
  Future<void> likePost(String postId) async {
    final String currentEmail = currentUser!.email!;
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);

    DocumentSnapshot postSnapshot = await postRef.get();
    if (!postSnapshot.exists) return;

    List likedBy = postSnapshot['likedBy'] ?? [];

    if (likedBy.contains(currentEmail)) {
      await postRef.update({
        'likedBy': FieldValue.arrayRemove([currentEmail]),
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await postRef.update({
        'likedBy': FieldValue.arrayUnion([currentEmail]),
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final secondaryText = Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bgColor,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.userEmail)
            .snapshots(),
        builder: (context, userSnapshot) {
          String displayUsername = widget.username;
          String displayProfilePic = widget.receiverImageUrl;
          String displayProfession = "User";
          String displayBio = "";

          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final data = userSnapshot.data!.data() as Map<String, dynamic>;
            displayUsername = data['username'] ?? widget.username;
            displayProfilePic = data['profilePic'] ?? widget.receiverImageUrl;
            displayProfession = data['profession'] ?? "User";
            displayBio = data['about'] ?? "No bio available.";
          }

          return CustomScrollView(
            slivers: [
              // 1. APP BAR (Floating)
              // SliverAppBar(
              //   expandedHeight: 120,
              //   pinned: true,
              //   backgroundColor: bgColor,
              //   leading: Container(
              //     margin: const EdgeInsets.all(8),
              //     decoration: const BoxDecoration(
              //       color: Colors.black54,
              //       shape: BoxShape.circle,
              //     ),
              //     child: IconButton(
              //       icon: const Icon(Icons.arrow_back, color: Colors.white),
              //       onPressed: () => Navigator.pop(context),
              //     ),
              //   ),
              //   flexibleSpace: FlexibleSpaceBar(
              //     background: Stack(
              //       fit: StackFit.expand,
              //       children: [
              //         // Header Banner (X Style)
              //         Container(
              //           decoration: const BoxDecoration(
              //             image: DecorationImage(
              //               image: NetworkImage(
              //                 "https://cdn.mos.cms.futurecdn.net/L8exumuVUaJatGHCPDRuQm.jpg",
              //               ),
              //               fit: BoxFit.cover,
              //             ),
              //           ),
              //         ),
              //         Container(
              //           decoration: BoxDecoration(
              //             gradient: LinearGradient(
              //               begin: Alignment.topCenter,
              //               end: Alignment.bottomCenter,
              //               colors: [
              //                 Colors.transparent,
              //                 Colors.black.withOpacity(0.8)
              //               ],
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              SliverAppBar(
                expandedHeight: 0, // No height needed for banner here
                pinned: true, // Keeps back button visible
                backgroundColor: bgColor, // Matches background or transparent
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black54, // Dark circle for visibility
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              // 2. PROFILE DETAILS HEADER
              // SliverToBoxAdapter(
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: 16),
              //     child: Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         // Avatar & Action Button Row
              //         Transform.translate(
              //           offset: const Offset(
              //               0, -35), // Move avatar up to overlap banner
              //           child: Row(
              //             crossAxisAlignment: CrossAxisAlignment.end,
              //             children: [
              //               // Profile Pic
              //               Container(
              //                 decoration: BoxDecoration(
              //                   shape: BoxShape.circle,
              //                   border: Border.all(
              //                       color: bgColor, width: 4), // Cutout effect
              //                 ),
              //                 child: CircleAvatar(
              //                   radius: 40,
              //                   backgroundColor: Colors.grey.shade200,
              //                   backgroundImage:
              //                       NetworkImage(displayProfilePic),
              //                 ),
              //               ),
              //               const Spacer(),
              //               Container(
              //                 margin: const EdgeInsets.only(
              //                   bottom: 7,
              //                 ),
              //                 child: OutlinedButton(
              //                   onPressed: () {
              //                     Navigator.push(context,
              //                         MaterialPageRoute(builder: (context) {
              //                       return ChatScreen(
              //                         receiverId: widget.userEmail,
              //                         receiverName: displayUsername,
              //                         receiverImageUrl: displayProfilePic,
              //                       );
              //                     }));
              //                   },
              //                   style: OutlinedButton.styleFrom(
              //                     side: BorderSide(
              //                       color: isDark
              //                           ? Colors.grey.shade700
              //                           : Colors.grey.shade600,
              //                     ),
              //                     shape: RoundedRectangleBorder(
              //                         borderRadius: BorderRadius.circular(20)),
              //                     padding: const EdgeInsets.symmetric(
              //                       horizontal: 12,
              //                     ),
              //                   ),
              //                   child: const FaIcon(FontAwesomeIcons.envelope,
              //                       color: Colors.black, size: 16),
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),

              //         Transform.translate(
              //           offset: const Offset(0, -25),
              //           child: Column(
              //             crossAxisAlignment: CrossAxisAlignment.start,
              //             children: [
              //               Text(
              //                 displayUsername,
              //                 style: TextStyle(
              //                   fontSize: 22,
              //                   fontWeight: FontWeight.w900,
              //                   color: textColor,
              //                 ),
              //               ),
              //               Text(
              //                 displayProfession,
              //                 style: TextStyle(
              //                   fontSize: 14,
              //                   color: secondaryText,
              //                 ),
              //               ),
              //               const SizedBox(height: 12),
              //               // Bio
              //               Text(
              //                 displayBio,
              //                 style: TextStyle(
              //                   fontSize: 15,
              //                   height: 1.4,
              //                   color: textColor,
              //                 ),
              //               ),
              //               const SizedBox(height: 12),
              //               // Meta Data (Joined Date)
              //               Row(
              //                 children: [
              //                   FaIcon(FontAwesomeIcons.calendar,
              //                       size: 14, color: secondaryText),
              //                   const SizedBox(width: 5),
              //                   Text(
              //                     "Joined September 2023", // You can store 'joinedAt' in Firebase later
              //                     style: TextStyle(
              //                         color: secondaryText, fontSize: 14),
              //                   ),
              //                 ],
              //               ),
              //               const SizedBox(height: 15),
              //               // Followers Count Row (Mockup for X style)
              //               Row(
              //                 children: [
              //                   _buildCount(textColor, "145", "Following"),
              //                   const SizedBox(width: 15),
              //                   _buildCount(textColor, "4,321", "Followers"),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         ),

              //         // Tabs (Posts / Replies / Media)
              //         const SizedBox(height: 10),
              //         Container(
              //           decoration: BoxDecoration(
              //             border: Border(
              //                 bottom: BorderSide(
              //                     color: Colors.grey.shade300, width: 0.5)),
              //           ),
              //           child: Row(
              //             children: [
              //               _buildTabItem(textColor, "Posts", true),
              //               _buildTabItem(textColor, "Replies", false),
              //               _buildTabItem(textColor, "Likes", false),
              //             ],
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              // 2. HEADER + AVATAR + DETAILS (Combined in one Adapter)
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.bottomLeft,
                      children: [
                        Container(
                          height: 150,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(
                                "https://cdn.mos.cms.futurecdn.net/L8exumuVUaJatGHCPDRuQm.jpg",
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8)
                                ],
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: -40,
                          left: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: bgColor, width: 4),
                            ),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: NetworkImage(displayProfilePic),
                            ),
                          ),
                        ),
                        // Action Button (Message)
                        Positioned(
                          bottom: -2,
                          right: 16,
                          child: Container(
                            margin: const EdgeInsets.only(top: 40),
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ChatScreen(
                                        receiverId: widget.userEmail,
                                        receiverName: displayUsername,
                                        receiverImageUrl: displayProfilePic,
                                      );
                                    },
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.grey.shade600
                                        : Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              child: const FaIcon(FontAwesomeIcons.envelope,
                                  size: 16),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Spacer to account for the Avatar hanging down (-40)
                    const SizedBox(height: 45),

                    // 3. USER INFO (Name, Bio, etc.)
                    Transform.translate(
                      offset: const Offset(18, 0), // Move up to reduce gap
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayUsername,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: textColor,
                            ),
                          ),
                          Text(
                            displayProfession,
                            style: TextStyle(
                              fontSize: 14,
                              color: secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Bio
                          Text(
                            displayBio,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.4,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Meta Data (Joined Date)
                          Row(
                            children: [
                              FaIcon(FontAwesomeIcons.calendar,
                                  size: 14, color: secondaryText),
                              const SizedBox(width: 5),
                              Text(
                                "Joined September 2023", // You can store 'joinedAt' in Firebase later
                                style: TextStyle(
                                    color: secondaryText, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          // Followers Count Row (Mockup for X style)
                          Row(
                            children: [
                              _buildCount(textColor, "145", "Following"),
                              const SizedBox(width: 15),
                              _buildCount(textColor, "4,321", "Followers"),
                            ],
                          ),
                          //  Tabs (Posts / Replies / Media)
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                                      color: Colors.grey.shade300, width: 0.5)),
                            ),
                            child: Row(
                              children: [
                                _buildTabItem(textColor, "Posts", true),
                                _buildTabItem(textColor, "Replies", false),
                                _buildTabItem(textColor, "Likes", false),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 3. POSTS LIST
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .where('email', isEqualTo: widget.userEmail)
                    // .orderBy('timeStamp', descending: true) // Ensure you have an index for this
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Center(
                          child: Column(
                            children: [
                              Text(
                                "No posts yet",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor),
                              ),
                              const SizedBox(height: 5),
                              Text("When they post, it will show up here.",
                                  style: TextStyle(color: secondaryText)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final posts = snapshot.data!.docs;

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final postData =
                            posts[index].data() as Map<String, dynamic>;
                        final postId = posts[index].id;
                        final userLiked = (postData['likedBy'] ?? [])
                            .contains(currentUser?.email);

                        return _buildPostItem(context, postData, postId,
                            userLiked, isDark, textColor);
                      },
                      childCount: posts.length,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // -- WIDGET: Post Item (Re-used clean style) --
  Widget _buildPostItem(BuildContext context, Map<String, dynamic> data,
      String postId, bool isLiked, bool isDark, Color textColor) {
    return Container(
      decoration: BoxDecoration(
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage:
                NetworkImage(data['profile'] ?? widget.receiverImageUrl),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Name + Username + Time
                Row(
                  children: [
                    Text(
                      data['username'] ?? "User",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: textColor),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      "@${data['username']?.toString().toLowerCase().replaceAll(" ", "")}",
                      style:
                          TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                    const Spacer(),
                    const Icon(Icons.more_horiz, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 4),

                // Text Content
                if (data['content'] != null &&
                    data['content'].toString().isNotEmpty)
                  Text(
                    data['content'],
                    style:
                        TextStyle(fontSize: 15, height: 1.3, color: textColor),
                  ),

                // Image Content
                if (data['imageUrl'] != null) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],

                // Action Buttons
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionIcon(FontAwesomeIcons.comment,
                        data['commentsCount']?.toString() ?? "0", false),
                    InkWell(
                      onTap: () => likePost(postId),
                      child: Row(
                        children: [
                          Icon(
                              isLiked
                                  ? FontAwesomeIcons.solidHeart
                                  : FontAwesomeIcons.heart,
                              size: 18,
                              color: isLiked ? Colors.pink : Colors.grey),
                          const SizedBox(width: 6),
                          Text(data['likesCount']?.toString() ?? "0",
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                    _buildActionIcon(
                        FontAwesomeIcons.retweet, "0", false), // Placeholder
                    _buildActionIcon(FontAwesomeIcons.shareNodes, "", false),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String count, bool active) {
    return Row(
      children: [
        FaIcon(icon, size: 18, color: Colors.grey),
        if (count.isNotEmpty) ...[
          const SizedBox(width: 6),
          Text(count, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ]
      ],
    );
  }

  Widget _buildCount(Color textColor, String count, String label) {
    return RichText(
      text: TextSpan(
        style:
            TextStyle(color: textColor, fontFamily: 'roboto'), // Default style
        children: [
          TextSpan(
              text: count, style: const TextStyle(fontWeight: FontWeight.bold)),
          const TextSpan(text: " "),
          TextSpan(text: label, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildTabItem(Color textColor, String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.only(right: 25, bottom: 10),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? textColor : Colors.grey,
            ),
          ),
          if (isActive)
            Container(
              margin: const EdgeInsets.only(top: 8),
              height: 3,
              width: 30,
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(2),
              ),
            )
        ],
      ),
    );
  }
}
