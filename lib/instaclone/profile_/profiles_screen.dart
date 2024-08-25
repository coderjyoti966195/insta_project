import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
 import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../controller/auth_controller.dart';
import '../controller/insta_login_screen.dart';
import '../controller/user_controller_.dart';
import '../vidoe_view/video/video_player.dart';
import '../vidoe_view/video/video_screen.dart';
import 'edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController userController = Get.put(UserController());
  final AuthController authController = Get.put(AuthController());

  RxInt postCount = 0.obs;
  RxInt followersCount = 0.obs;
  RxInt followingCount = 0.obs;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final userId = userController.user.value.id;
    if (userId != null) {
      try {
        final userProfile = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        final userData = userProfile.data();

        followersCount.value = (userData?['followers'] as List?)?.length ?? 0;
        followingCount.value = (userData?['following'] as List?)?.length ?? 0;

        final postSnapshot = await FirebaseFirestore.instance
            .collection('videos')
            .where('userId', isEqualTo: userId)
            .get();

        postCount.value = postSnapshot.docs.length;
      } catch (e) {
        print("Error loading user profile data: $e");
      }
    }
  }

  Future<String?> _generateThumbnail(String videoUrl) async {
    try {
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.JPEG,
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
        title: Text(userController.userData.name ?? 'Username'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                FirebaseAuth.instance.signOut();
                Get.offAll(() => InstaLoginScreen());
              }
            },
            itemBuilder: (BuildContext context) {
              return {'logout'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Obx(() {
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                CircleAvatar(
                                  radius: 35,
                                  backgroundImage: userController.userData.imageUrl != null
                                      ? NetworkImage(userController.userData.imageUrl!)
                                      : null,
                                  child: userController.userData.imageUrl == null
                                      ? Icon(Icons.person, size: 50, color: Colors.grey)
                                      : null,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  userController.userData.name ?? 'Username',
                                  style: TextStyle(
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            _buildProfileStat('Posts', postCount.value.toString()),
                            _buildProfileStat('Followers', followersCount.value.toString()),
                            _buildProfileStat('Following', followingCount.value.toString()),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            OutlinedButton(
                              onPressed: () {
                                Get.to(() => EditProfileScreen());
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text('Edit Profile'),
                            ),
                            OutlinedButton(
                              onPressed: () {
                                Get.to(() => VideoUploadScreen(
                                  onVideoUploaded: _refreshProfileScreen,
                                ));
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text('Add Video Post'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
          // Post Grid
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('videos')
                  .where('userId', isEqualTo: userController.user.value.id)
                  .snapshots(),
              builder: (context, snapshot) {
                final videoDocs = snapshot.data?.docs ?? [];

                if (videoDocs.isEmpty) {
                  return Center(child: Text('No videos uploaded yet.'));
                }

                return GridView.builder(
                  padding: EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: videoDocs.length,
                  itemBuilder: (context, index) {
                    final videoData = videoDocs[index];
                    final videoUrl = videoData['videoUrl'];

                    return FutureBuilder<String?>(
                      future: _generateThumbnail(videoUrl),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Center(child: Icon(Icons.error));
                        }
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => VideoPlaybackScreen(videoUrl: videoUrl));
                          },
                          child: Image.file(
                            File(snapshot.data!),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStat(String title, String count) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  _refreshProfileScreen() {
    _loadProfileData();
  }
}
