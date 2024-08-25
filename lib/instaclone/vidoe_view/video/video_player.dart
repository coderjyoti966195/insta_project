import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlaybackScreen extends StatefulWidget {
  final String videoUrl;

  VideoPlaybackScreen({required this.videoUrl});

  @override
  _VideoPlaybackScreenState createState() => _VideoPlaybackScreenState();
}

class _VideoPlaybackScreenState extends State<VideoPlaybackScreen> {
  late VideoPlayerController _controller;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Playback'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? GestureDetector(
          onTap: _togglePlayPause,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              if (!isPlaying)
                Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 80.0,
                ),
            ],
          ),
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}

