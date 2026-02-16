import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:socialapp/services/gemini_chat_service.dart';

class AiSummaryScreen extends StatefulWidget {
  final String postContent;
  final String? imageUrl;

  const AiSummaryScreen({super.key, required this.postContent, this.imageUrl});

  @override
  State<AiSummaryScreen> createState() => _AiSummaryScreenState();
}

class _AiSummaryScreenState extends State<AiSummaryScreen> {
  late Future<String> _summaryFuture;

  @override
  void initState() {
    super.initState();
    final GeminiChatService _geminiService = GeminiChatService();
    _summaryFuture = _geminiService.getPostSummary(
      postContent: widget.postContent,
      imageUrl: widget.imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/modelicon.png",
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "AI Summary",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'poppins',
                color: textColor,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<String>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Colors.blueAccent,
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Reading post...",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 50, color: Colors.redAccent),
                    const SizedBox(height: 10),
                    const Text(
                      "Failed to analyze post.",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Markdown(
                data: snapshot.data!,
                selectable: true,
                padding: const EdgeInsets.all(20),
                styleSheet: MarkdownStyleSheet(
                  p: TextStyle(
                    fontSize: 16,
                    height: 1.6,
                    fontFamily: 'roboto',
                    color: textColor,
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                  h1: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  h2: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  listBullet: TextStyle(color: textColor),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
