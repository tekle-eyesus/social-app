import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/video_model.dart';

class FeedOverlay extends StatelessWidget {
  final VideoModel video;

  const FeedOverlay({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1. Bottom Left: User Info
        Positioned(
          bottom: 20,
          left: 15,
          right: 100, // Leave space for right actions
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                video.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),

        // 2. Right Side: Actions
        Positioned(
          bottom: 20,
          right: 10,
          child: Column(
            children: [
              _buildAction(FontAwesomeIcons.solidHeart, video.likes.toString(),
                  Colors.red),
              const SizedBox(height: 20),
              _buildAction(FontAwesomeIcons.solidCommentDots,
                  video.comments.toString(), Colors.white),
              const SizedBox(height: 20),
              _buildAction(FontAwesomeIcons.share, "Share", Colors.white),
              const SizedBox(height: 30), // Padding from bottom
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAction(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                Colors.black.withOpacity(0.2), // Subtle background for contrast
            shape: BoxShape.circle,
          ),
          child: FaIcon(icon, size: 28, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(blurRadius: 2, color: Colors.black)],
          ),
        ),
      ],
    );
  }
}
