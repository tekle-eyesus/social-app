import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/helpers/helper_functions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:socialapp/helpers/snackbar_helper.dart';
import 'package:socialapp/widget/full_screen_image.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String currentUserId;
  late String roomId;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  final cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
    cache: false,
  );
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(pickedFile.path,
            resourceType: CloudinaryResourceType.Image),
      );

      await _sendMessage(imageUrl: response.secureUrl, type: 'image');
    } catch (e) {
      CustomSnackBar.showError(context, "Failed to upload image: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _sendMessage(
      {String? text, String? imageUrl, String type = 'text'}) async {
    if (type == 'text' && (text == null || text.trim().isEmpty)) return;

    if (type == 'text') _controller.clear();

    await _firestore
        .collection('chats')
        .doc(roomId)
        .collection('messages')
        .add({
      'text': text ?? '',
      'imageUrl': imageUrl ?? '',
      'type': type, // 'text' or 'image'
      'senderId': currentUserId,
      'receiverId': widget.receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

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

                    return _buildMessageBubble(message, isSentByMe);
                  },
                );
              },
            ),
          ),

          // Input Area
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isSentByMe) {
    final String type = message['type'] ?? 'text';
    final String text = message['text'] ?? '';
    final String imageUrl = message['imageUrl'] ?? '';

    return Align(
      alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSentByMe ? Colors.black : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isSentByMe
                ? const Radius.circular(16)
                : const Radius.circular(2),
            bottomRight: isSentByMe
                ? const Radius.circular(2)
                : const Radius.circular(16),
          ),
          // ... shadow logic ...
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 12), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // --- DISPLAY LOGIC ---
            if (type == 'image')
              GestureDetector(
                onTap: () {
                  // Optional: Open full screen image
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => FullScreenImage(
                              imageFile: imageUrl, tag: imageUrl)));
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: 200,
                        color: Colors.grey.shade800,
                        child: const Center(
                            child:
                                CircularProgressIndicator(color: Colors.white)),
                      );
                    },
                  ),
                ),
              )
            else
              Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: isSentByMe ? Colors.white : Colors.black87,
                ),
              ),

            const SizedBox(height: 4),

            // --- TIMESTAMP ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatTimestamp(message['timestamp']),
                  style: TextStyle(
                    fontSize: 10,
                    color: isSentByMe ? Colors.white70 : Colors.black45,
                  ),
                ),
                if (isSentByMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 14, color: Colors.white70),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.paperclip,
                  size: 20, color: Colors.grey),
              onPressed: _isUploading
                  ? null
                  : () => _pickAndUploadImage(ImageSource.gallery),
            ),

// 2. Update the Camera Icon
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.camera,
                  size: 20, color: Colors.grey),
              onPressed: _isUploading
                  ? null
                  : () => _pickAndUploadImage(ImageSource.camera),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 5, // Auto-grow
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Message...",
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () =>
                  _sendMessage(text: _controller.text.trim(), type: 'text'),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_upward,
                          color: Colors.white, size: 20),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
