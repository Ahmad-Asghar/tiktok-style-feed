import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tiktok_style_feed/screens/auth/home/provider/home_provider.dart';
import 'package:video_player/video_player.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videoProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      body: videoProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : videoProvider.videoUrls.isEmpty
          ? const Center(child: Text("No videos found"))
          : PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: videoProvider.videoUrls.length,
        itemBuilder: (context, index) {
          return VideoPlayerItem(videoUrl: videoProvider.videoUrls[index]);
        },
      ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerItem({required this.videoUrl, super.key});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _controller.setLooping(true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _controller.value.isInitialized
            ? SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller.value.size.width,
              height: _controller.value.size.height,
              child: VideoPlayer(_controller),
            ),
          ),
        )
            : const Center(child: CircularProgressIndicator()),

        // Action Buttons
        Positioned(
          right: 16,
          bottom: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {
                  // Like toggle logic here
                },
                icon: const Icon(Icons.favorite, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              IconButton(
                onPressed: () {
                  // Save logic here
                },
                icon: const Icon(Icons.bookmark, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 16),
              IconButton(
                onPressed: () {
                  // Download logic here
                },
                icon: const Icon(Icons.download, color: Colors.white, size: 30),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
