import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../controller/insta_login_screen.dart';


class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: Center(
        child: TextField(
          onTap: (){_logout(context);},
          decoration: InputDecoration(hintText: "Logout"),
        ),
      ),
    );
  }
  Future<void> _logout(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => InstaLoginScreen()),
          (Route<dynamic> route) => false,
    );
  }
}