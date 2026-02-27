import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_model.dart';

class FeedController extends ChangeNotifier {
  // Mock Data (Replace with Firebase logic later)
  List<VideoModel> videos = [
    VideoModel(
      id: '1',
      username: '@tech_guru',
      caption: 'Flutter is amazing! #coding',
      likes: 1200,
      comments: 45,
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
    ),
    VideoModel(
      id: '2',
      username: '@nature_lover',
      caption: 'Look at this view 🏔️',
      likes: 3400,
      comments: 120,
      videoUrl:
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    ),
    VideoModel(
      id: '3',
      username: '@skater_boi',
      caption: 'Nailed the trick!',
      likes: 890,
      comments: 12,
      videoUrl:
          'https://assets.mixkit.co/videos/preview/mixkit-young-mother-with-her-little-daughter-decorating-a-christmas-tree-39745-large.mp4',
    ),
  ];

  // Map to manage controllers: Key = Index, Value = Controller
  final Map<int, VideoPlayerController> _controllers = {};

  Map<int, VideoPlayerController> get controllers => _controllers;

  // Initialize the first video immediately
  int _currentIndex = 0;

  FeedController() {
    _initializeControllerAtIndex(0);
    _initializeControllerAtIndex(1); // Preload next
  }

  VideoPlayerController? getController(int index) => _controllers[index];

  /// CORE LOGIC: Called whenever the PageView snaps to a new index
  void onPageChanged(int index) {
    _currentIndex = index;

    // 1. Play current video
    _initializeControllerAtIndex(index);
    _playControllerAtIndex(index);

    // 2. Preload next video
    _initializeControllerAtIndex(index + 1);

    // 3. Dispose previous video (Index - 1) to save memory
    // Note: Some apps keep index-1 for smooth back-swiping.
    // Here we strictly dispose anything 2 pages away as requested,
    // but pausing index-1 is better than disposing immediately if users scroll up often.
    _stopControllerAtIndex(index - 1);
    _disposeControllerAtIndex(index - 2);

    // 4. Dispose future videos if user scrolled back up
    _disposeControllerAtIndex(index + 2);

    notifyListeners();
  }

  Future<void> _initializeControllerAtIndex(int index) async {
    if (index < 0 || index >= videos.length) return;
    if (_controllers.containsKey(index)) return; // Already initialized

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(videos[index].videoUrl),
    );

    _controllers[index] = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      if (index == _currentIndex) {
        _playControllerAtIndex(index);
      }
    } catch (error) {
      debugPrint('Failed to load video at index $index: $error');
      await controller.dispose();
      _controllers.remove(index);
    } finally {
      notifyListeners(); // Notify UI to redraw (remove loading spinner)
    }
  }

  void _playControllerAtIndex(int index) {
    final controller = _controllers[index];
    if (controller == null || !controller.value.isInitialized) return;
    controller.play();
  }

  void _stopControllerAtIndex(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]!.pause();
    }
  }

  void _disposeControllerAtIndex(int index) {
    if (_controllers.containsKey(index)) {
      _controllers[index]!.dispose();
      _controllers.remove(index);
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }
}
