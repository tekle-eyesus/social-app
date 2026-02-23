import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatelessWidget {
  final VideoPlayerController? controller;

  const VideoPlayerItem({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    if (controller != null && controller!.value.isInitialized) {
      return GestureDetector(
        onTap: () {
          // Toggle Play/Pause on tap
          controller!.value.isPlaying
              ? controller!.pause()
              : controller!.play();
        },
        child: SizedBox.expand(
          child: FittedBox(
            // Covers the screen (Crop/Zoom) to mimic TikTok style
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller!.value.size.width,
              height: controller!.value.size.height,
              child: VideoPlayer(controller!),
            ),
          ),
        ),
      );
    } else {
      // Loading State
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
  }
}
