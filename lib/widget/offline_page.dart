import 'package:flutter/material.dart';
import 'package:socialapp/theme/app_colors.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.primaryText,
        leading: const Row(
          children: [
            SizedBox(
              width: 6,
            ),
            CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage(
                'assets/icon/icon.png',
              ),
            ),
          ],
        ),
        title: const Text(
          "WeTok",
          style: TextStyle(
              fontSize: 22,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 21, 45, 81)),
        ),
      ),
      body: Container(
        color: Colors.red.shade50,
        width: double.infinity,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.wifi_off, size: 100, color: Colors.red),
            SizedBox(height: 20),
            Text("No Internet Connection", style: TextStyle(fontSize: 24)),
            Text("Please check your settings."),
          ],
        ),
      ),
    );
  }
}
