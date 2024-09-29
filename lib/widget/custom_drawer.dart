import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:socialapp/screens/HomeScreen.dart';
import 'package:socialapp/screens/login_screen.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    void handleSignOut() {
      FirebaseAuth.instance.signOut();
    }

    return Drawer(
      // backgroundColor: Theme.of(context).colorScheme.background,
      backgroundColor: Colors.blue.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              DrawerHeader(
                  child: Icon(
                Icons.heart_broken,
                color: Theme.of(context).colorScheme.primary,
              )),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  leading: Icon(Icons.home,
                      color: const Color.fromARGB(255, 20, 34, 54)),
                  title: const Text(
                    "H O M E",
                    style: TextStyle(fontFamily: 'poppins'),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  leading: Icon(
                    Icons.people_sharp,
                    color: const Color.fromARGB(255, 20, 34, 54),
                  ),
                  title: const Text("P R O F I L E",
                      style: TextStyle(fontFamily: 'poppins')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/profileScreen");
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: ListTile(
                  leading: const Icon(
                    Icons.person,
                    color: const Color.fromARGB(255, 20, 34, 54),
                  ),
                  title: const Text("U S E R S",
                      style: TextStyle(fontFamily: 'poppins')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, "/usersScreen");
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 15),
            child: ListTile(
              leading: Icon(
                Icons.logout_outlined,
                color: Colors.red.shade900,
              ),
              title: const Text(
                "L O G O U T",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: handleSignOut,
            ),
          )
        ],
      ),
    );
  }
}
