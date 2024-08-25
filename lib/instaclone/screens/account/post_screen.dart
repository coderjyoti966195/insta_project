import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../vidoe_view/video/user_list_.dart';

import 'comment_screen.dart';

class PostWidget extends StatefulWidget {
  final String mediaUrl;
  final bool isVideo;
  final String postId;
  final String userId;
  final String title;
  final String caption;
  final int initialLikes;
  final Function? onFollow;
  final Function? onRemove;

  PostWidget({
    Key? key,
    required this.mediaUrl,
    required this.isVideo,
    required this.postId,
    required this.userId,
    required this.title,
    required this.caption,
    required this.initialLikes,
    this.onFollow,
    this.onRemove,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late int _likes;
  late bool _isLiked;
  VideoPlayerController? _videoController;
  String _username = '';
  String _profileImage = '';
  int _commentCount = 0;
  bool _isFollowing = false;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _likes = widget.initialLikes;
    _isLiked = false;

    if (widget.isVideo) {
      _videoController = VideoPlayerController.network(widget.mediaUrl)
        ..initialize().then((_) {
          setState(() {});

          _videoController?.play();
          _likes = 0;
        });
    }

    _fetchUserInfo();
    _checkIfLiked();
    _fetchCommentCount();
    _checkIfFollowing();
  }

  Future<void> _fetchUserInfo() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _username = userDoc['name'] ?? 'Username';
          _profileImage = userDoc['image'] ?? '';
        });
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }

  Future<void> _checkIfLiked() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final postDoc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .get();
    if (postDoc.exists) {
      List<dynamic> likes = postDoc['likes'] ?? [];
      setState(() {
        _isLiked = likes.contains(currentUser.uid);
      });
    }
  }

  Future<void> _fetchCommentCount() async {
    try {
      final commentsSnapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId)
          .collection('comments')
          .get();

      setState(() {
        _commentCount = commentsSnapshot.size;
      });
    } catch (e) {
      print('Error fetching comment count: $e');
    }
  }

  Future<void> _checkIfFollowing() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    if (currentUserDoc.exists) {
      List<dynamic> following = currentUserDoc['following'] ?? [];
      setState(() {
        _isFollowing = following.contains(widget.userId);
      });
    }
  }

  Future<void> _followUser() async  {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final currentUserDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    final userDoc = await userDocRef.get();
    final currentUserDoc = await currentUserDocRef.get();

    if (userDoc.exists && currentUserDoc.exists) {
      final List<dynamic> followers = List.from(userDoc['followers'] ?? []);
      final List<dynamic> following = List.from(currentUserDoc['following'] ?? []);

      if (!_isFollowing) {
        followers.add(currentUser.uid);
        following.add(widget.userId);
      } else {
        followers.remove(currentUser.uid);
        following.remove(widget.userId);
      }

      await userDocRef.update({'followers': followers});
      await currentUserDocRef.update({'following': following});

      setState(() {
        _isFollowing = !_isFollowing;
      });
    }
  }


  Future<void> _toggleLike() async {
    List<dynamic> likes = [];

    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final postDocRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);
    final postDoc = await postDocRef.get();
    final postDoc1 = postDoc.data();

    if (postDoc.exists) {
      try{
        likes = postDoc1?['likes'] ?? [];
        if (_isLiked) {
          likes.remove(currentUser.uid);
        } else {
          likes.add(currentUser.uid);
        }
        await postDocRef.update({'likes': likes});
      }catch(e){
      }
      setState(() {
        _isLiked = !_isLiked;
        _likes = likes.length;
      });
    }
  }

  Future<void> _removePost() async {
    try {
      await FirebaseFirestore.instance.collection('posts').doc(widget.postId).delete();
      if (widget.onRemove != null) {
        widget.onRemove!();
      }
    } catch (e) {
      print('Error removing post: $e');
    }
  }

  void _showCommentsSheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => CommentContent(postId: postId, videoId: '',),
    );
  }

  void _showUserListForSending(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => UserListScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {


    return Stack(
      children: [
        Container(
          height: double.infinity,
          width: double.infinity,
          child: widget.isVideo
              ? _videoController != null && _videoController!.value.isInitialized
              ? AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          )
              : Center(child: CircularProgressIndicator())
              : CachedNetworkImage(
            imageUrl: widget.mediaUrl,
            placeholder: (context, url) => Center(child: CircularProgressIndicator()),
            errorWidget: (context, url, error) => Icon(Icons.error),
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: _profileImage.isNotEmpty
                        ? NetworkImage(_profileImage)
                        : AssetImage('assets/default_profile.png')
                    as ImageProvider,
                    radius: 28,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _username,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      await _followUser();
                      if (widget.onFollow != null) {
                        widget.onFollow!();
                      }
                    },
                    child: Text(_isFollowing ? "Follow" : "Following"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                widget.caption,
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: 10,
          child: Column(
            children: [
              IconButton(
                // icon: Icon(Icons.favorite),
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.white,
                ),
                onPressed: (){
                  setState(() {
                    _isLiked = !_isLiked; // Toggle the liked state
                    if(_isLiked){
                      _likes += 1; // Update the like count

                    }else{
                      _likes -= 1 ; // Update the like count

                    }


                  });
                } /*_toggleLike*/,
              ),
              Text(
                '$_likes',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.comment, color: Colors.white),
                onPressed: () {
                  _showCommentsSheet(context, widget.postId);
                },
              ),
              Text(
                '$_commentCount',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(height: 10),
              IconButton(
                icon: Icon(Icons.send, color: Colors.white),
                onPressed: () {
                  _showUserListForSending(context);
                },
              ),
              PopupMenuButton<int>(
                icon: Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Text("Remove"),
                  ),
                ],
                onSelected: (value) {
                  if (value == 0) {
                    _removePost();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
