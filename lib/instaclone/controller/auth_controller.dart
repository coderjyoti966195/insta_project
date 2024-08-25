import 'dart:convert';
import 'dart:io';
 import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';

import '../home/insta_home_screen.dart';
import '../model/model_screen.dart';
import 'insta_login_screen.dart';


class AuthController extends GetxController {
  static AuthController instance = Get.find();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  Rxn<User?> firebaseUser = Rxn<User?>();
  Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onReady() {
    super.onReady();
    firebaseUser.bindStream(auth.userChanges());
    ever(firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    if (user == null) {
      Get.offAll(InstaLoginScreen());
    } else {
      fetchUserProfile(user.uid);
      Get.offAll(InstaHomeScreen());
    }
  }

  Future<void> registerWithEmailAndPassword(String name, String email,
      String password, String phone, File? image) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String? imageUrl;
      if (image != null) {
        String fileName = '${userCredential.user!.uid}.png';
        Reference ref = storage.ref().child('user_images/$fileName');
        await ref.putFile(image);
        imageUrl = await ref.getDownloadURL();
      }

      UserModel newUser = UserModel(
          id: userCredential.user!.uid,
          email: email,
          phone: phone,
          name: name,
          imageUrl: imageUrl,
          post: [],
          followers: [],
          following: [],
          likes: [],
          comments: []
      );

      await firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(newUser.toJson());

      fetchUserProfile(userCredential.user!.uid);
      Get.offAll(InstaHomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  loginWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      fetchUserProfile(userCredential.user!.uid);
      Get.offAll(InstaHomeScreen());
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', e.message ?? 'An error occurred');
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
      Get.offAll(()=>InstaLoginScreen());
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out. Please try again.');
      print('Error during sign out: $e');
    }
  }

  fetchUserProfile(String userId) async {
    try {
      DocumentSnapshot doc =
      await firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        currentUser.value = UserModel.fromJson(jsonDecode(jsonEncode(doc.data())));
        print("User fetched: ${currentUser.value}");
      } else {
        Get.snackbar('Error', 'User not found');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch user profile');
    }
  }

  Future<void> updateProfile({required String name, File? imageFile}) async {
    try {
      String? imageUrl;
      if (imageFile != null) {
        final storageRef = FirebaseStorage.instance.ref().child('profile_images').child('${DateTime.now().toIso8601String()}.jpg');
        final uploadTask = storageRef.putFile(imageFile);
        final snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      await FirebaseFirestore.instance.collection('users').doc(currentUser.value?.id).update({
        'name': name,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

    } catch (e) {
      print('Failed to update profile: $e');
    }
  }



  var isLoading = false.obs;
  var searchedUsers = [].obs;

  void searchUsers(String query) async {
    if (query.isEmpty) {
      searchedUsers.clear();
      return;
    }

    isLoading.value = true;

    try {
      QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .get();

      searchedUsers.value = usersSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error searching users: $e");
      searchedUsers.clear();
    } finally {
      isLoading.value = false;
    }
  }
}