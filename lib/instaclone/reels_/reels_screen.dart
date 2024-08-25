import 'package:chewie/chewie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../controller/user_controller_.dart';
import '../model/model_screen.dart';
import '../screens/account/comment_screen.dart';
import '../vidoe_view/video/user_list_.dart';

class ReelsScreen extends StatefulWidget {
  final String? videoId;

  const ReelsScreen({Key? key, this.videoId}) : super(key: key);
  _ReelsScreenState createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  PageController _pageController = PageController();
  List<DocumentSnapshot> videoDocs = [];
  var userController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    _fetchVideos();
  }

  Future<void> _fetchVideos() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('videos').get();
      setState(() {
        videoDocs = snapshot.docs;
      });
    } catch (e) {
      print("Error fetching videos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: videoDocs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: videoDocs.length,
        itemBuilder: (context, index) {
          final videoData = videoDocs[index];
          final videoUrl = videoData['videoUrl'];

          final userId = videoData['userId'];

          return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return Center(child: Text('User data not found'));
              }

              final userData = snapshot.data!.data() as Map<String, dynamic>;
              final username = userData['name'] ?? 'Unknown User';
              final profileUrl = userData['imageUrl'] ??
                  'https://www.example.com/default_profile.png';
              var authorData = UserModel.fromJson(userData);

              return VideoPlayerItem(
                videoUrl: videoUrl,
                username: username,
                profileUrl: profileUrl,
                authorId: userId,
                followers: authorData.followers ?? [],
                following: authorData.following ?? [],
                // likes: authorData.likes ?? [],
                userController: userController,
                videoId: videoData.id,
              );
            },
          );
        },
      ),
    );
  }
}
class VideoPlayerItem extends StatefulWidget {
  final String videoUrl;
  final String username;
  final String profileUrl;
  final String authorId;
  final List<String> followers;
  final List<String> following;
  final UserController userController;
  final String videoId;

  VideoPlayerItem({
    required this.videoUrl,
    required this.username,
    required this.profileUrl,
    required this.authorId,
    required this.followers,
    required this.following,
    required this.userController,
    required this.videoId,
  });

  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  RxBool isPlaying = true.obs;
  RxBool isLiked = false.obs;
  RxInt likeCount = 0.obs;
  RxInt commentCount = 0.obs;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _controller,
          aspectRatio: _controller.value.aspectRatio,
          autoPlay: true,
          looping: true,
          showControls: false,
        );
        _controller.play();
        _fetchLikeStatus();
        _fetchLikeCount();
        fetchCommentCount();
      });
  }
  Future<void> fetchCommentCount() async {
    try {
      QuerySnapshot commentSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .collection('comments')
          .get();
      commentCount.value = commentSnapshot.size;
    } catch (e) {
      print("Error fetching comment count: $e");
    }
  }
  Future<void> _fetchLikeStatus() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      DocumentSnapshot videoSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .get();

      List<dynamic> likes = videoSnapshot['likes'] ?? [];
      isLiked.value = likes.contains(userId);
    } catch (e) {
      print("Error fetching like status: $e");
    }
  }

  Future<void> _fetchLikeCount() async {
    try {
      DocumentSnapshot videoSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .doc(widget.videoId)
          .get();

      likeCount.value = videoSnapshot['likeCount'] ?? 0;
    } catch (e) {
      print("Error fetching like count: $e");
    }
  }

  Future<void> toggleLike() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    isLiked.value = !isLiked.value;

    if (isLiked.value) {
      widget.userController.addLikeVideo(widget.authorId, widget.videoId);
      likeCount.value++;
    }
    else {
      widget.userController.removeFromLike(widget.authorId, widget.videoId);
      likeCount.value--;
    }
  }
  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  void togglePlayPause() {
    isPlaying.value = !isPlaying.value;
    if (isPlaying.value) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          GestureDetector(
            onTap: togglePlayPause,
            child: _controller.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : Center(
                child: CupertinoActivityIndicator(
                  color: Colors.white,
                )
            ),
          ),

          if (!isPlaying.value)
            Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 80.0,
              ),
            ),

          Positioned(
            left: 16.0,
            bottom: 20.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(widget.profileUrl),
                      radius: 20.0,
                    ),
                    SizedBox(width: 10),
                    Text(
                      widget.username,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    SizedBox(width: 20),
                    if (widget.followers
                        .contains(FirebaseAuth.instance.currentUser?.uid))
                      OutlinedButton(
                        onPressed: () {
                          widget.userController
                              .removeFromFollowing(widget.authorId);
                        },
                        child: const Text(
                          "Following",
                          style: TextStyle(color: Colors.blue),
                        ),
                      )
                    else
                      OutlinedButton(
                        onPressed: () {
                          widget.userController
                              .addToFollowing(widget.authorId);
                        },
                        child: Text(
                          "Follow",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                const Text(
                  "Some description for the video...",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(height: 8),
              ],
            ),
          ),

          Positioned(
            right: 16.0,
            bottom: 60.0,
            child: Column(
              children: [
                Column(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked.value
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: isLiked.value ? Colors.red : Colors.white,
                      ),
                      onPressed: toggleLike,
                    ),
                    Text(
                      '${likeCount.value}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.comment, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => CommentContent(videoId: widget.videoId, postId: '',),
                      isScrollControlled: true,
                    );
                  },
                ),
                Text(
                  '${commentCount.value}',
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    _showUserListForSending(context);
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  void _showUserListForSending(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => UserListScreen(),
    );
  }
}

