import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/widget/chat_message_input.dart';
import 'package:socialapp/widget/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImageUrl;

  const ChatScreen({
    required this.receiverId,
    required this.receiverName,
    required this.receiverImageUrl,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScrollController _scrollController = ScrollController();
  late String currentUserId;
  late String roomId;

  @override
  void initState() {
    super.initState();
    currentUserId = _auth.currentUser?.email ?? "";
    roomId = getRoomId(currentUserId, widget.receiverId);
  }

  String getRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? "${userId1}_$userId2"
        : "${userId2}_$userId1";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), // Light grey background
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.receiverImageUrl),
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.receiverName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      "Online",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat List Area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(roomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.black));
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message =
                        messages[index].data() as Map<String, dynamic>;
                    bool isSentByMe = message['senderId'] == currentUserId;

                    return MessageBubble(
                      message: message,
                      isSentByMe: isSentByMe,
                    );
                  },
                );
              },
            ),
          ),

          // Input Area
          ChatMessageInput(
            receiverId: widget.receiverId,
            scrollController: _scrollController,
            roomId: roomId,
            currentUserId: currentUserId,
          ),
        ],
      ),
    );
  }
}
