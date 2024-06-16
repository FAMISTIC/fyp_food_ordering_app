import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/components/reusable_widget.dart';

import 'login_page.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _register() async {
    try {
      String cleanedPhoneNumber = _phoneController.text.replaceAll(RegExp(r'\D'), '');

      bool phoneExists = await _checkIfPhoneExists(cleanedPhoneNumber);
      if (phoneExists) {
        _showErrorDialog('Error', 'Phone number already exists');
        return;
      }

      bool usernameExists = await _checkIfUsernameExists(_nameController.text);
      if (usernameExists) {
        _showErrorDialog('Error', 'Username already exists');
        return;
      }

      User? user = await FirebaseAuthService().registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      // Additional user details
      String name = _nameController.text;
      String phone = cleanedPhoneNumber;
      String imageLink = "";

      // Store additional user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': name,
        'phone': phone,
        'imageLink': imageLink,
      });

      // Successfully registered
      print("User registered: ${user.email}");

      // Navigate to login page after successful registration
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      // Handle registration errors
      print("Failed to register: $e");
      // You can show a user-friendly message to the user here.
    }
  }

  Future<bool> _checkIfPhoneExists(String phone) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  Future<bool> _checkIfUsernameExists(String username) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('name', isEqualTo: username)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: const Color.fromARGB(224, 234, 47, 13),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
      ),
      key: _formKey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Registration', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color: Color.fromARGB(224, 234, 47, 13))),
            const SizedBox(height: 40),
            reusableTextField(
              "Enter Email",
              Icons.email,
              false,
              _emailController,
            ),
            const SizedBox(height: 16.0),
            reusableTextField(
              "Enter Password (min: 6 characters)",
              Icons.lock,
              true,
              _passwordController,
            ),
            const SizedBox(height: 16.0),
            reusableTextField(
              "Enter UserName",
              Icons.person_outline,
              false,
              _nameController,
            ),
            const SizedBox(height: 16.0),
            reusableTextField(
              "Enter Phone",
              Icons.calendar_today,
              false,
              _phoneController,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                String cleanedPhoneNumber = _phoneController.text.replaceAll(RegExp(r'\D'), '');

                // Call the register function when the button is pressed
                if (_nameController.text.isEmpty &&
                    _emailController.text.isEmpty &&
                    _passwordController.text.length < 6 &&
                    _phoneController.text.isEmpty) {
                  _showErrorDialog('Error', 'Please insert all the fields');
                  return;
                }
                if (_nameController.text.isEmpty) {
                  _showErrorDialog('Error', 'Username cannot be empty');
                  return;
                }
                if (_nameController.text.toLowerCase() == 'admin' ||
                    _nameController.text.toLowerCase() == 'superadmin') {
                  _showErrorDialog('Error', 'User cannot name admin');
                  return;
                }
                if (!_emailController.text.contains('@')) {
                  _showErrorDialog('Error', 'Invalid email');
                  return;
                }
                if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
                  _showErrorDialog('Error', 'Invalid password');
                  return;
                }
                if (!isValidPhoneNumber(cleanedPhoneNumber)) {
                  _showErrorDialog('Error', 'Invalid Phone Format');
                  return;
                }

                _register();
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(225, 245, 93, 66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool isValidPhoneNumber(String phone) {
    // Customize this regex based on the desired phone number format
    // This example allows a format like 1234567890
    RegExp regExp = RegExp(r'^\d{10}$');
    return regExp.hasMatch(phone);
  }
}
