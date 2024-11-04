import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialapp/screens/HomeScreen.dart';

class PostScreen extends StatefulWidget {
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _messageController = TextEditingController();

  Future pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<String> uploadImage(File image) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.amber,
            ),
          );
        });
    if (_image != null) {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(image);
      TaskSnapshot taskSnapshot = await uploadTask;
      Navigator.pop(context);
      return await taskSnapshot.ref.getDownloadURL();
    } else {
      Navigator.pop(context);
      return "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.townandcountrymag.com%2Fleisure%2Farts-and-culture%2Fa40363815%2Fjon-snow-game-of-thrones-spinoff%2F&psig=AOvVaw20xJWECdi9kOW7o7tALQpx&ust=1727658958911000&source=images&cd=vfe&opi=89978449&ved=0CBQQjRxqFwoTCKj40uj95ogDFQAAAAAdAAAAABAJ";
    }
  }

  void handlePost(String? imageUrl) async {
    var userData;
    User? loggedUser = FirebaseAuth.instance.currentUser;
    FirebaseFirestore db = FirebaseFirestore.instance;
    if (_messageController.text.isNotEmpty) {
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.amber,
              ),
            );
          });

      final docRef = db.collection("users").doc(loggedUser!.email);
      await docRef.get().then(
        (DocumentSnapshot doc) {
          userData = doc.data() as Map<String, dynamic>;
          // ...
          print(userData);
        },
        onError: (e) => print("Error getting document: $e"),
      );

      await db.collection("posts").doc().set({
        "imageUrl": imageUrl,
        "content": _messageController.text,
        "email": loggedUser.email,
        "username": userData['username'],
        "profile": userData['profilePic'],
        "timeStamp": DateTime.now().toIso8601String(),
      });
      Navigator.pop(context);
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        width: 200,
        duration: const Duration(seconds: 1),
        content: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 50),
          height: 44,
          decoration: BoxDecoration(
              color: Colors.deepPurple.shade200,
              borderRadius: BorderRadius.circular(12)),
          child: Text(
            "POSTED !!!",
            style: TextStyle(
                color: Colors.deepPurple.shade600, fontFamily: 'poppins'),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        width: 200,
        duration: const Duration(seconds: 1),
        content: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 50),
          height: 44,
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Say something!!",
            style: TextStyle(
                color: Colors.deepPurple.shade600, fontFamily: 'poppins'),
          ),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ));
    }
  }

  Future<void> createPost(String message, File? image) async {
    String? imageUrl;

    if (image != null) {
      imageUrl = await uploadImage(image);
    }

    // print(imageUrl);
    // print(message);

    handlePost(imageUrl);

    // Save post to Firestore
    // await FirebaseFirestore.instance.collection('posts').add({
    //   'message': message,
    //   'imageUrl': imageUrl,
    //   'timestamp': FieldValue.serverTimestamp(),
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade100,
        title: const Text(
          'Create Post',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.only(top: 10, bottom: 10, left: 6, right: 3),
              decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(
                    color: Colors.blue,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6)),
              child: TextField(
                maxLength: 50,
                controller: _messageController,
                decoration: InputDecoration(
                    hintText: 'Enter your message', border: InputBorder.none),
              ),
            ),
            SizedBox(height: 15),
            _image != null
                ? Container(
                    clipBehavior: Clip.hardEdge,
                    height: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Image.file(
                      _image!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                : Row(
                    children: [
                      Icon(
                        Icons.image,
                        color: Colors.green,
                      ),
                      Text('No image selected.'),
                    ],
                  ),
            SizedBox(height: 15),
            Row(
              children: [
                ElevatedButton(
                  style: ButtonStyle(
                    padding: const MaterialStatePropertyAll(
                      EdgeInsets.symmetric(
                        horizontal: 45,
                      ),
                    ),
                    iconColor: const MaterialStatePropertyAll(Colors.amber),
                    backgroundColor: MaterialStatePropertyAll(
                      Color.fromARGB(255, 151, 236, 14),
                    ),
                  ),
                  onPressed: pickImage,
                  child: Text(
                    'Pick Image',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                await createPost(_messageController.text, _image);

                // ScaffoldMessenger.of(context)
                //     .showSnackBar(SnackBar(content: Text('Post Created!')));
                // _messageController.clear();
                setState(() {
                  _image = null;
                });
              },
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(top: 10, left: 5, right: 5),
                alignment: Alignment.center,
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blue.shade300,
                    borderRadius: BorderRadius.circular(5)),
                child: const Text(
                  'POST',
                  style: TextStyle(
                      color: Colors.white, fontFamily: 'poppins', fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
