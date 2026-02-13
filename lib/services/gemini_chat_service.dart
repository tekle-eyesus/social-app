import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';

class GeminiChatService {
  final _apiKey = dotenv.env['GEMINI_API_KEY']!;
  late final GenerativeModel _model;

  GeminiChatService() {
    _model = GenerativeModel(
      model: 'gemini-flash-latest',
      apiKey: _apiKey,
    );
  }

  /// Downloads the image from the network and returns bytes + mimeType
  Future<({Uint8List bytes, String mimeType})?> _downloadImage(
      String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        // Try to get mime from url extension, fallback to header or jpeg
        String? mime = lookupMimeType(url) ?? response.headers['content-type'];
        return (bytes: bytes, mimeType: mime ?? 'image/jpeg');
      }
    } catch (e) {
      print("Error downloading image: $e");
    }
    return null;
  }

  Future<String> getPostSummary({
    required String postContent,
    String? imageUrl,
  }) async {
    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // 1. Handle Text + Image
        final imageData = await _downloadImage(imageUrl);

        if (imageData != null) {
          final imagePrompt = '''
            You are an AI integrated into a social media app. 
            Analyze the following social media post which contains an image and text.
            
            1. Briefly describe what is in the image.
            2. Explain the context: How does the image relate to the caption: "$postContent"?
            3. Detect the sentiment (Humorous, Serious, News, Personal, etc.).
            4. Provide a 2-sentence summary of the entire post.
            
            Keep the tone conversational and helpful.
          ''';

          final content = [
            Content.multi([
              TextPart(imagePrompt),
              DataPart(imageData.mimeType, imageData.bytes),
            ])
          ];

          final response = await _model.generateContent(content);
          return response.text ?? "Could not summarize image post.";
        }
      }

      // 2. Handle Text Only (Fallback or if no image provided)
      final prompt = _buildTextPrompt(postContent);
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? "Could not summarize text.";
    } catch (e) {
      return "Unable to generate summary at this time. ($e)";
    }
  }

  String _buildTextPrompt(String postContent) {
    return '''
      You are an AI assistant ("Grok-style") in a social media app.
      Your task is to summarize the following user post.

      Post Content: "$postContent"

      Instructions:
      - Capture the core message or news.
      - Detect the underlying tone (sarcasm, excitement, rant, etc).
      - If the text is very short, explain the context if possible, otherwise just expand slightly on the meaning.
      - Keep the response concise (max 3 sentences).
    ''';
  }
}
