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
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const UsersScreen(),
    PostScreen(),
    const NotifyScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const unselectedItemColor = Colors.grey;
    final backgroundColor = isDarkMode
        ? const Color(0xFF000000)
        : const Color(
            0xFFFFFFFF,
          );
    final selectedItemColor = isDarkMode
        ? const Color(0xFFFFFFFF)
        : const Color(
            0xFF0F1419,
          );

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: backgroundColor,
          selectedItemColor: selectedItemColor,
          unselectedItemColor: unselectedItemColor,
          showSelectedLabels: false, // X style: hide labels
          showUnselectedLabels: false,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.house, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.house, size: 24),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.users, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.users, size: 24),
              label: 'Users',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: _currentIndex == 2
                        ? (isDarkMode ? Colors.white : Colors.black)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isDarkMode ? Colors.white : Colors.black,
                        width: 1.5)),
                child: FaIcon(
                  FontAwesomeIcons.plus,
                  size: 18,
                  // Invert color if selected
                  color: _currentIndex == 2
                      ? (isDarkMode ? Colors.black : Colors.white)
                      : (isDarkMode ? Colors.white : Colors.black),
                ),
              ),
              label: 'Post',
            ),
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.bell, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.solidBell, size: 24),
              label: 'Notifications',
            ),
            const BottomNavigationBarItem(
              icon: FaIcon(FontAwesomeIcons.user, size: 24),
              activeIcon: FaIcon(FontAwesomeIcons.solidUser, size: 24),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
