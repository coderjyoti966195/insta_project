import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/insta_login_screen.dart';

import '../home/insta_home_screen.dart';

class InstaSplashScreen extends StatefulWidget {
  const InstaSplashScreen({super.key});

  @override
  State<InstaSplashScreen> createState() => _InstaSplashScreenState();
}

class _InstaSplashScreenState extends State<InstaSplashScreen> {
  @override
  void initState() {
    Timer(
      Duration(seconds: 3),
          () {
        checkUser();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("KrisCent",style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold,color: Colors.black),),
      ),
    );
  }

  void checkUser() async {
    bool isLogin = FirebaseAuth.instance.currentUser?.uid != null;
    if (isLogin) {
      Get.offAll(() => InstaHomeScreen());
    } else {
      Get.offAll(() => InstaLoginScreen());
    }
  }
}

