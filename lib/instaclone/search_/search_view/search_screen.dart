import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
 import '../../reels_/reels_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<List<Map<String, dynamic>>> _fetchPostsWithUsers() async {
    List<Map<String, dynamic>> postsWithUsers = [];

    try {
      QuerySnapshot postsSnapshot = await FirebaseFirestore.instance.collection('videos').get();
      print("Posts fetched: ${postsSnapshot.docs.length}");

      for (var postDoc in postsSnapshot.docs) {
        Map<String, dynamic> postData = postDoc.data() as Map<String, dynamic>;
        print("Post data: $postData");

        if (postData.containsKey('userId')) {
          String userId = postData['userId'];
          DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

          if (userDoc.exists) {
            Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
            postData['userName'] = userData['name'] ?? 'Unknown';
            postData['userImageUrl'] = userData['imageUrl'] ?? '';
            postData['videoId'] = postData['videoId'] ?? '';
            postData['thumbnailUrl'] = postData['thumbnailUrl'] ?? '';
            postData['title'] = postData['title'] ?? 'No Title';
            postsWithUsers.add(postData);
          }
        }
      }
      print("Posts with users: $postsWithUsers");
    } catch (e) {
      print('Error fetching posts: $e');
    }

    return postsWithUsers;
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        // imageFormat: ImageFormat.JPEG,
        maxHeight: 300,
        quality: 75,
      );
      print("Thumbnail generated: $thumbnailPath");
      return thumbnailPath;
    } catch (e) {
      print("Error generating thumbnail: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search users or videos...',
            hintStyle: const TextStyle(color: Colors.black),
            fillColor: Colors.white,
            filled: true,
            prefixIcon: const Icon(Icons.search, color: Color(0xff71a08b)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPostsWithUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No posts found.'));
          }

          List<Map<String, dynamic>> posts = snapshot.data!;

          if (_searchQuery.isNotEmpty) {
            posts = posts.where((post) {
              final userName = post['userName']?.toLowerCase() ?? '';
              final videoTitle = post['title']?.toLowerCase() ?? '';
              return userName.contains(_searchQuery.toLowerCase()) || videoTitle.contains(_searchQuery.toLowerCase());
            }).toList();
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.75,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              var post = posts[index];
              print("Post for grid item: $post");

              return InkWell(
                onTap: () {
                  String? videoId = post['videoId'];
                  if (videoId != null && videoId.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReelsScreen(
                          videoId: videoId,
                        ),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Video ID is not available.')),
                    );
                  }
                },
                child: GridTile(
                  header: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(post['userImageUrl'] ?? ''),
                      child: post['userImageUrl'] == null ? Icon(Icons.person) : null,
                    ),
                    title: Text(post['userName'] ?? 'Unknown'),
                  ),
                  child: FutureBuilder<String?>(
                    future: _generateThumbnail(post['videoUrl'] ?? ''),
                    builder: (context, thumbnailSnapshot) {
                      if (thumbnailSnapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (thumbnailSnapshot.hasError || !thumbnailSnapshot.hasData) {
                        return Center(child: Icon(Icons.error));
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReelsScreen(
                                videoId: post['videoId'] ?? '',
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          File(thumbnailSnapshot.data!),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

