import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/screens/chat_screen.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
        title: Text("USERS"),
        backgroundColor: Colors.blue.shade100,
        actions: [
          IconButton(
            onPressed: () {},
            icon: FaIcon(
              FontAwesomeIcons.search,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  } else if (snapshot.data!.docs.isEmpty) {
                    return const Text("No users found!!");
                  } else if (snapshot.hasData) {
                    //List of all users data in the database
                    List<DocumentSnapshot> users = snapshot.data!.docs;
                    return ListView.builder(
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        //single user data as a map
                        Map<String, dynamic> userData =
                            users[index].data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          child: ListTile(
                            trailing: IconButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: ((context) {
                                    return ChatScreen(
                                        receiverId: userData['email'],
                                        receiverName: userData['username'],
                                        receiverImageUrl:
                                            userData['profilePic']);
                                  })));
                                },
                                icon: FaIcon(
                                  FontAwesomeIcons.message,
                                  color: Colors.lightBlue.shade900,
                                  size: 27,
                                )),
                            leading: Container(
                              clipBehavior: Clip.hardEdge,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blue,
                                    offset: Offset(4, 2),
                                    blurRadius: 10,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Image.network(
                                userData["profilePic"],
                                fit: BoxFit.cover,
                                height: 50,
                              ),
                            ),
                            title: Text(
                              userData['username'],
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 20,
                                color: Color.fromARGB(255, 8, 70, 121),
                              ),
                            ),
                            subtitle: Text(
                              userData['profession'] ?? "unknown",
                              style: const TextStyle(
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Text("no data");
                  }
                }),
          ),
        ],
      ),
    );
  }
}
