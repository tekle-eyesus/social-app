import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:socialapp/auth/model/user_model.dart';
import 'package:socialapp/helpers/snackbar_helper.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  final UserModel? userModel;

  const SettingsScreen({super.key, this.userModel});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Local State for Toggles (In a real app, use Provider/Bloc)
  bool _isDarkMode = false;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _biometricLogin = false;
  String _selectedLanguage = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Settings",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          // --- SECTION 1: ACCOUNT ---
          _buildSectionHeader("Account"),
          _buildSettingsTile(
            icon: FontAwesomeIcons.userPen,
            title: "Edit Profile",
            onTap: () {
              if (widget.userModel != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          EditProfileScreen(user: widget.userModel!)),
                );
              } else {
                CustomSnackBar.showError(context, "User data not available");
              }
            },
          ),
          _buildSettingsTile(
            icon: FontAwesomeIcons.lock,
            title: "Change Password",
            onTap: () =>
                CustomSnackBar.showInfo(context, "Password flow coming soon!"),
          ),
          _buildSwitchTile(
            icon: FontAwesomeIcons.fingerprint,
            title: "Biometric Login",
            value: _biometricLogin,
            onChanged: (val) => setState(() => _biometricLogin = val),
          ),

          const SizedBox(height: 25),

          // --- SECTION 2: APPEARANCE ---
          _buildSectionHeader("Appearance"),
          _buildSwitchTile(
            icon: FontAwesomeIcons.moon,
            title: "Dark Mode",
            value: _isDarkMode,
            onChanged: (val) {
              setState(() => _isDarkMode = val);
              // TODO: Implement global theme toggle logic here
              CustomSnackBar.showInfo(context,
                  _isDarkMode ? "Dark Mode Enabled" : "Light Mode Enabled");
            },
          ),
          _buildSettingsTile(
            icon: FontAwesomeIcons.globe,
            title: "Language",
            trailingText: _selectedLanguage,
            onTap: _showLanguageBottomSheet,
          ),

          const SizedBox(height: 25),

          // --- SECTION 3: NOTIFICATIONS ---
          _buildSectionHeader("Notifications"),
          _buildSwitchTile(
            icon: FontAwesomeIcons.solidBell,
            title: "Push Notifications",
            value: _pushNotifications,
            onChanged: (val) => setState(() => _pushNotifications = val),
          ),
          _buildSwitchTile(
            icon: FontAwesomeIcons.envelope,
            title: "Email Updates",
            value: _emailNotifications,
            onChanged: (val) => setState(() => _emailNotifications = val),
          ),

          const SizedBox(height: 25),

          // --- SECTION 4: SUPPORT & LOGOUT ---
          _buildSectionHeader("Support"),
          _buildSettingsTile(
            icon: FontAwesomeIcons.circleQuestion,
            title: "Help Center",
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: FontAwesomeIcons.shieldHalved,
            title: "Privacy Policy",
            onTap: () {},
          ),

          const SizedBox(height: 30),

          // Log Out Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: OutlinedButton(
              onPressed: _handleLogout,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red.shade100),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.red.shade50,
              ),
              child: Text(
                "Log Out",
                style: TextStyle(
                    color: Colors.red.shade700, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Version 1.0.0",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Standard Navigation Tile
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: FaIcon(icon, size: 16, color: Colors.black),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            if (trailingText != null) const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // Switch Toggle Tile
  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: FaIcon(icon, size: 16, color: Colors.black),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.black, // Tech theme active color
          activeTrackColor: Colors.grey.shade400,
          inactiveThumbColor: Colors.grey.shade100,
          inactiveTrackColor: Colors.grey.shade300,
        ),
      ),
    );
  }

  // --- LOGIC ---

  void _showLanguageBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final languages = ["English", "Spanish", "French", "German", "Amharic"];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Select Language",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              ...languages.map((lang) => ListTile(
                    title: Text(lang),
                    trailing: _selectedLanguage == lang
                        ? const Icon(Icons.check, color: Colors.black)
                        : null,
                    onTap: () {
                      setState(() => _selectedLanguage = lang);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Out"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await FirebaseAuth.instance.signOut();

              // Depending on your navigation setup, assume root is the wrapper
              // This pops all routes until the first one (usually AuthWrapper)
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login', (Route<dynamic> route) => false);
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
