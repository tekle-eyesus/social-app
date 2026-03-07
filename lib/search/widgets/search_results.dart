import 'package:flutter/material.dart';
import 'package:socialapp/auth/model/user_model.dart';
import 'package:socialapp/screens/user_profile_screen.dart';

class SearchResults extends StatelessWidget {
  final UserModel user;
  const SearchResults({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => UserProfileScreen(
                      userEmail: user.email,
                      receiverImageUrl: user.profilePic ?? '',
                      username: user.username ?? '',
                    )));
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.shade200),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: NetworkImage(
                user.profilePic ?? 'https://via.placeholder.com/150'),
          ),
        ),
      ),
      title: Text(
        user.username ?? 'Unknown',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
      subtitle: Text(
        user.profession ?? 'No Role',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey.shade300),
    );
  }
}
