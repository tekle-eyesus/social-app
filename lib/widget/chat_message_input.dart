import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialapp/helpers/snackbar_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatMessageInput extends StatefulWidget {
  final String receiverId;
  final ScrollController _scrollController;
  late String roomId;
  late String currentUserId;
  ChatMessageInput(
      {super.key,
      required this.receiverId,
      required ScrollController scrollController,
      required this.roomId,
      required this.currentUserId})
      : _scrollController = scrollController;

  @override
  State<ChatMessageInput> createState() => _ChatMessageInputState();
}

class _ChatMessageInputState extends State<ChatMessageInput> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  bool _isUploading = false;

  // Cloudinary Configuration
  final cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '',
    dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '',
    cache: false,
  );

  Future<void> _sendMessage(
      {String? text, String? imageUrl, String type = 'text'}) async {
    if (type == 'text' && (text == null || text.trim().isEmpty)) return;

    if (type == 'text') _controller.clear();

    await _firestore
        .collection('chats')
        .doc(widget.roomId)
        .collection('messages')
        .add({
      'text': text ?? '',
      'imageUrl': imageUrl ?? '',
      'type': type, // 'text' or 'image'
      'senderId': widget.currentUserId,
      'receiverId': widget.receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    if (widget._scrollController.hasClients) {
      widget._scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

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

  @override
  Widget build(BuildContext context) {
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
