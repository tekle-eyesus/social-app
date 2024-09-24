import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text("Users"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            } else if (snapshot.data!.docs.isEmpty) {
              return Text("No users found!!");
            } else if (snapshot.hasData) {
              List<DocumentSnapshot> users = snapshot.data!.docs;
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> userData =
                      users[index].data() as Map<String, dynamic>;
                  return ListTile(
                    title: Text(userData['username']),
                    subtitle: Text(userData['email']),
                  );
                },
              );
            } else {
              return Text("no data");
            }
          }),
    );
  }
}
