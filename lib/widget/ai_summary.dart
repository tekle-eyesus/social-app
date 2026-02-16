import 'package:flutter/material.dart';
import 'package:socialapp/services/gemini_chat_service.dart';

class AiSummary extends StatelessWidget {
  String? imageUrl;
  String postContent;
  AiSummary({super.key, required this.postContent, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final GeminiChatService _geminiService = GeminiChatService();
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .scaffoldBackgroundColor, // Adapts to Dark/Light mode
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Handle Bar ---
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Header ---
          Row(
            children: [
              Image.asset(
                "assets/images/modelicon.png",
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 10),
              const Text(
                "AI Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
            ],
          ),
          const Divider(height: 30),

          // --- Content (Future Builder) ---
          Expanded(
            child: FutureBuilder<String>(
              future: _geminiService.getPostSummary(
                postContent: postContent,
                imageUrl: imageUrl,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.blueAccent),
                        SizedBox(height: 15),
                        Text(
                          "Analyzing post...",
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      "Failed to load summary.",
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                } else if (snapshot.hasData) {
                  return Text(
                    snapshot.data!,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontFamily: 'roboto',
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
