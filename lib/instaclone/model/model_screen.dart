// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:get/get.dart';
// //
// // class Comment {
// //   final String username;
// //   final String profileImage;
// //   final String commentText;
// //   final DateTime timestamp;
// //
// //   Comment({
// //     required this.username,
// //     required this.profileImage,
// //     required this.commentText,
// //     required this.timestamp,
// //   });
// // }
// //
// // class UserModel {
// //   final String profilePicUrl;
// //   final int followers;
// //   final int following;
// //
// //   UserModel({
// //     required this.profilePicUrl,
// //     required this.followers,
// //     required this.following,
// //   });
// //
// //   factory UserModel.fromDocument(DocumentSnapshot doc) {
// //     return UserModel(
// //       profilePicUrl: doc['profilePicUrl'] ?? '',
// //       followers: doc['followers'] ?? 0,
// //       following: doc['following'] ?? 0,
// //     );
// //   }
// // }
// //
// // class PostController extends GetxController {
// //   var posts = <dynamic>[].obs;
// //   var user = UserModel(profilePicUrl: '', followers: 0, following: 0).obs;
// //
// //   @override
// //   void onInit() {
// //     super.onInit();
// //     fetchUserData();
// //     fetchPosts();
// //   }
// //
// //   void fetchPosts() async {
// //     try {
// //       QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('posts').get();
// //       posts.value = snapshot.docs.map((doc) => doc.data()).toList();
// //     } catch (e) {
// //       print("Error fetching posts: $e");
// //     }
// //   }
// //
// //   void fetchUserData() async {
// //     try {
// //       DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc('USER_ID').get();
// //       user.value = UserModel.fromDocument(userDoc);
// //     } catch (e) {
// //       print("Error fetching user data: $e");
// //     }
// //   }
// // }
//
// import 'dart:convert';
//
// UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));
//
// String userModelToJson(UserModel data) => json.encode(data.toJson());
//
// class UserModel {
//   String? id;
//   String? name;
//   String? email;
//   String? phone;
//   String? imageUrl;
//   List<String>? followers;
//   List<String>? following;
//   // List<String>? likes;
//   // List<String>? comment;
//
//   UserModel({
//     this.id,
//     this.name,
//     this.email,
//     this.phone,
//     this.imageUrl,
//     this.followers,
//     this.following,
//     // this.likes,
//     // this.comment
//   });
//
//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//     id: json["id"],
//     name: json["name"],
//     email: json["email"],
//     phone: json["phone"],
//     imageUrl: json["imageUrl"],
//     // likes: json["likes"],
//     // comment: json["comments"],
//     followers: json["followers"] == null ? [] : List<String>.from(json["followers"]!.map((x) => x)),
//     following: json["following"] == null ? [] : List<String>.from(json["following"]!.map((x) => x)),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "name": name,
//     "email": email,
//     "phone": phone,
//     "imageUrl": imageUrl,
//     // "likes": likes,
//     // "comments": comment,
//     "followers": followers == null ? [] : List<dynamic>.from(followers!.map((x) => x)),
//     "following": following == null ? [] : List<dynamic>.from(following!.map((x)=>x)),
//   };
// }
//

import 'dart:convert';

class UserModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? imageUrl;
  List<String>? followers;
  List<String>? following;
  List<String>? post;
  List<String>? likes;
  List<String>? comments;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.imageUrl,
    this.post,
    this.followers,
    this.following,
    this.likes,
    this.comments,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    imageUrl: json["imageUrl"],
    post: json["post"] == null ? [] : List<String>.from(json["post"]!.map((x) => x)),
    followers: json["followers"] == null ? [] : List<String>.from(json["followers"]!.map((x) => x)),
    following: json["following"] == null ? [] : List<String>.from(json["following"]!.map((x) => x)),
    likes: json["likes"] == null ? [] : List<String>.from(json["likes"]!.map((x) => x)),
    comments: json["comments"] == null ? [] : List<String>.from(json["comments"]!.map((x) => x)),
  );

  get profileImageUrl => null;


  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "imageUrl": imageUrl,
    "post": post == null ? [] : List<dynamic>.from(post!.map((x) => x)),
    "followers": followers == null ? [] : List<dynamic>.from(followers!.map((x) => x)),
    "following": following == null ? [] : List<dynamic>.from(following!.map((x) => x)),
    "likes": likes == null ? [] : List<dynamic>.from(likes!.map((x) => x)),
    "comments": comments == null ? [] : List<dynamic>.from(comments!.map((x) => x)),
  };
}

