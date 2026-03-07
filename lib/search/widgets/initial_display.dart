import 'package:flutter/material.dart';

class InitialDisplay extends StatelessWidget {
  const InitialDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search_outlined,
              size: 80, color: Colors.grey.shade200),
          const SizedBox(height: 10),
          Text(
            "Find people to follow",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
