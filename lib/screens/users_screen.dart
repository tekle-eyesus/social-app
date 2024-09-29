import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: Colors.blue.shade100,
      // appBar: AppBar(
      //   title: Text("USERS"),
      //   // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      // ),
      body: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.blue.shade400,
                    ),
                    child: Icon(Icons.arrow_back_ios_outlined)),
              ),
              Text(
                "U S E R S",
                style: TextStyle(
                    color: Colors.blue.shade900,
                    fontSize: 20,
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold),
              ),
              Container(
                  padding: EdgeInsets.all(5.4),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      borderRadius: BorderRadius.circular(5)),
                  child: Icon(Icons.search))
            ],
          ),
          Expanded(
            child: StreamBuilder(
                stream:
                    FirebaseFirestore.instance.collection('users').snapshots(),
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
                        return Container(
                          margin: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: Colors.blue.shade600)),
                          child: ListTile(
                            trailing: IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.message,
                                  color: Colors.lightBlue.shade900,
                                  size: 27,
                                )),
                            leading: Icon(Icons.person),
                            title: Text(
                              userData['username'],
                              style: TextStyle(
                                fontFamily: 'poppins',
                              ),
                            ),
                            subtitle: Text(
                              userData['email'],
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
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
