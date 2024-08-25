import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'auth_controller.dart';
import 'mixin_class.dart';

class InstaLoginScreen extends StatelessWidget with ValidationMixin {
  final AuthController authController = Get.find<AuthController>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      // appBar: AppBar(
      //   title: Text('Login'),
      //   backgroundColor: Colors.blue,
      // ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 110),
                Text("Login Here",style: TextStyle(color: Colors.black,fontSize: 30,fontWeight: FontWeight.bold),),
                SizedBox(height: 200),
                _buildTextField(_emailController, 'Email', Icons.email, false),
                SizedBox(height: 30),
                _buildTextField(_passwordController, 'Password', Icons.lock, true),
                SizedBox(height: 30),
                MaterialButton(
                  color: Colors.blue,
                  minWidth: 370,
                  height: 50,
                  shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () {
                    if (_emailController.text.isNotEmpty &&
                        _passwordController.text.isNotEmpty) {
                      authController.loginWithEmailAndPassword(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      );
                    } else {
                      Get.snackbar('Error', 'Please fill all fields.');
                    }
                  },
                  child: Text('Login', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 40),
                Text.rich(
                  TextSpan(
                    text: 'Don\'t have an account? ',
                    style: TextStyle(color: Colors.blue,fontSize: 20),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()..onTap =(){
                          Get.toNamed('/register');
                        },
                        text: 'Sign Up Here',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon, bool isPassword) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.blue), // Changed to blue
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      obscureText: isPassword,
      validator: isPassword ? validatePassword : validateEmail,
    );
  }
}