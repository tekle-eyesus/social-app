import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  final String receiverId;
  final String receiverName;
  final String receiverImageUrl;

  ChatScreen({
    required this.receiverId, // user email
    required this.receiverName,
    required this.receiverImageUrl,
    super.key,
  });

  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('hh:mm a').format(date);
  }

  String getRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? "$userId1\_$userId2"
        : "$userId2\_$userId1";
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final currentUserId = _auth.currentUser?.email;
    final roomId = getRoomId(currentUserId!, receiverId);

    Future<void> _sendMessage() async {
      if (_controller.text.trim().isEmpty) return;

      await _firestore
          .collection('chats')
          .doc(roomId)
          .collection('messages')
          .add({
        'text': _controller.text.trim(),
        'senderId': currentUserId,
        'receiverId': receiverId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _controller.clear();
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90,
        backgroundColor: Colors.blue.shade200,
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            CircleAvatar(
              backgroundImage: NetworkImage(receiverImageUrl),
            ),
          ],
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(receiverName, style: TextStyle(fontSize: 18)),
            const Text(
              "Online",
              style: TextStyle(fontSize: 13, color: Colors.green),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/chat1.jpg', // Background image path
                    fit: BoxFit.cover,
                  ),
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('chats')
                      .doc(roomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final messages = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        bool isSentByMe = message['senderId'] == currentUserId;

                        return Align(
                          alignment: isSentByMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            // margin: const EdgeInsets.symmetric(vertical: 4),
                            margin: (!isSentByMe)
                                ? EdgeInsets.only(right: 25, top: 4, bottom: 4)
                                : EdgeInsets.only(left: 25, top: 4, bottom: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSentByMe
                                  ? Colors.blue.shade200
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(15),
                                topRight: const Radius.circular(15),
                                bottomLeft: isSentByMe
                                    ? const Radius.circular(15)
                                    : const Radius.circular(0),
                                bottomRight: isSentByMe
                                    ? const Radius.circular(0)
                                    : const Radius.circular(15),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  message['text'] ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "08:00 AM", // Ideally format this from timestamp
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    if (isSentByMe) const SizedBox(width: 5),
                                    if (isSentByMe)
                                      Icon(
                                        Icons.done_all,
                                        size: 15,
                                        color: Colors.blue.shade600,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            color: Colors.blue.shade100,
            child: Row(
              children: [
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.smile),
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(27),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Type a message",
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.paperclip),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.camera),
                  onPressed: () {},
                ),
                Container(
                  width: 42,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blue,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
