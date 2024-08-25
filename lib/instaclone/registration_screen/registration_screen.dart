import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/auth_controller.dart';
import '../controller/mixin_class.dart';

class InstaRegistrationScreen extends StatefulWidget {
  @override
  _InstaRegistrationScreenState createState() => _InstaRegistrationScreenState();
}

class _InstaRegistrationScreenState extends State<InstaRegistrationScreen> with ValidationMixin {
  final AuthController authController = Get.find<AuthController>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  File? _image;

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.camera_alt, color: Colors.blue, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Upload Profile Picture',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 80),
                _buildTextField(_nameController, 'Name', Icons.person, false),
                SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email, false),
                SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password', Icons.lock, true),
                SizedBox(height: 20),
                _buildTextField(_phoneController, 'Phone', Icons.phone, false),
                SizedBox(height: 40),
                MaterialButton(
                  shape: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.blue,
                  minWidth: 370,
                  height: 50,
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _image != null) {
                      authController.registerWithEmailAndPassword(
                        _nameController.text.trim(),
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                        _phoneController.text.trim(),
                        _image!,
                      );
                      Get.toNamed('/home');
                    } else {
                      Get.snackbar('Error', 'Please fill all fields and pick an image.');
                    }
                  },
                  child: Text('Register', style: TextStyle(fontSize: 20)),
                ),
                SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(color: Colors.blue,fontSize: 18),
                    children: [
                      TextSpan(
                        recognizer: TapGestureRecognizer()..onTap = () {
                          Get.toNamed('/login');
                        },
                        text: 'Login',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
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
        prefixIcon: Icon(icon, color: Colors.blue),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ),
      obscureText: isPassword,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your $labelText';
        }
        return null;
      },
    );
  }
}