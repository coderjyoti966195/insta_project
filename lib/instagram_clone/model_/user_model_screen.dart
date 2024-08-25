import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String profileImageUrl;
  final String email;
  final String uid;
  final String photoUrl;
  final String uniqueId;
  final String username;
  final String bio;
  final String createdAccount;
  final List<dynamic> followers; // Use dynamic if the type is mixed
  final List<dynamic> following; // Use dynamic if the type is mixed

  const User({
    required this.profileImageUrl,
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.uniqueId,
    required this.createdAccount,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
  });

  factory User.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      profileImageUrl: snapshot['profileImageUrl'] ?? '', // Default value if missing
      username: snapshot['username'] ?? '',
      uid: snapshot['uid'] ?? '',
      uniqueId: snapshot['uniqueId'] ?? '',
      createdAccount: snapshot['createdAccount'] ?? '',
      email: snapshot['email'] ?? '',
      photoUrl: snapshot['photoUrl'] ?? '',
      bio: snapshot['bio'] ?? '',
      followers: snapshot['followers'] ?? [], // Default to empty list if missing
      following: snapshot['following'] ?? [], // Default to empty list if missing
    );
  }

  Map<String, dynamic> toJson() => {
    'profileImageUrl': profileImageUrl,
    'username': username,
    'uid': uid,
    'email': email,
    'photoUrl': photoUrl,
    'uniqueId': uniqueId,
    'createdAccount': createdAccount,
    'bio': bio,
    'followers': followers,
    'following': following,
  };
}
