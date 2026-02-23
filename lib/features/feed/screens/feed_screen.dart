import 'package:flutter/material.dart';
import '../controllers/feed_controller.dart';
import '../widgets/feed_overlay.dart';
import '../widgets/video_player_item.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  // We use a local instance here, but in a real app,
  // you might provide this via Provider/GetX/Bloc at the top level.
  final FeedController _feedController = FeedController();

  @override
  void dispose() {
    _feedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background for loading states

      // Use AnimatedBuilder to listen to controller changes
      // without needing a full state management package dependency for this example
      body: AnimatedBuilder(
        animation: _feedController,
        builder: (context, child) {
          return PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _feedController.videos.length,
            onPageChanged: _feedController.onPageChanged,
            itemBuilder: (context, index) {
              final videoData = _feedController.videos[index];
              final videoController = _feedController.getController(index);

              return Stack(
                fit: StackFit.expand,
                children: [
                  // 1. The Video Layer
                  VideoPlayerItem(controller: videoController),

                  // 2. The Gradient Layer (Text Readability)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.6),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.2, 0.8, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // 3. The UI Overlay Layer
                  FeedOverlay(video: videoData),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
