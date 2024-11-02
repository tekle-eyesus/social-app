import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socialapp/screens/HomeScreen.dart';
import 'package:socialapp/screens/notify_screen.dart';
import 'package:socialapp/screens/post_screen.dart';
import 'package:socialapp/screens/profile_screen.dart';
import 'package:socialapp/screens/users_screen.dart';

class TabScreen extends StatefulWidget {
  const TabScreen({super.key});

  @override
  State<TabScreen> createState() => _TabScreenState();
}

class _TabScreenState extends State<TabScreen> {
  var index = 0;

  final screens = [
    HomeScreen(),
    UsersScreen(),
    PostScreen(),
    NotifyScreen(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      bottomNavigationBar: CurvedNavigationBar(
        index: index,
        height: 55,
        color: Colors.blueAccent,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color.fromARGB(255, 29, 100, 221),
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          Icon(
            Icons.home,
            size: 26,
            color: Colors.white,
          ),
          Icon(
            Icons.people,
            size: 26,
            color: Colors.white,
          ),
          Icon(
            Icons.add,
            size: 26,
            color: Colors.white,
          ),
          Icon(
            Icons.notifications,
            size: 26,
            color: Colors.white,
          ),
          Icon(
            Icons.person,
            size: 26,
            color: Colors.white,
          ),
        ],
        onTap: (index) {
          //Handle button tap
          setState(() {
            this.index = index;
          });
        },
      ),
      body: screens[index],
    );
  }
}
