import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
        color: const Color.fromARGB(255, 17, 77, 180),
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: const Color.fromARGB(255, 6, 16, 88),
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          FaIcon(
            FontAwesomeIcons.home,
            size: 22,
            color: Colors.white,
          ),
          FaIcon(
            FontAwesomeIcons.users,
            size: 22,
            color: Colors.white,
          ),
          FaIcon(
            FontAwesomeIcons.add,
            size: 26,
            color: Color.fromARGB(255, 141, 244, 6),
          ),
          FaIcon(
            FontAwesomeIcons.solidBell,
            size: 22,
            color: Colors.white,
          ),
          FaIcon(
            FontAwesomeIcons.userAstronaut,
            size: 22,
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
