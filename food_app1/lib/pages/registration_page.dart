// ignore_for_file: use_build_context_synchronously, use_key_in_widget_constructors, library_private_types_in_public_api

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
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Message'),
            content: const Text('Registered successfully'),
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
      User? user = await FirebaseAuthService().registerWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      // Additional user details
      String name = _nameController.text;
      int phone = int.tryParse(_phoneController.text) ?? 0;
      String imageLink ="";

      // Validate and handle errors for name and age if needed

      // Store additional user details in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
        'name': name,
        'phone': phone,
        'imageLink':imageLink,
        //'imageLink': imageLink,
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

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _formKey,
      appBar: AppBar(
      backgroundColor: Colors.transparent,
        title: const Text('Registration Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            reusableTextField(
                  "Enter Email Id",
                  Icons.person_outline,
                  false,
                  _emailController,
                ),
            const SizedBox(height: 16.0),
            reusableTextField(
                  "Enter Password",
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
                if(_nameController.text.isEmpty && _emailController.text.isEmpty && _passwordController.text.length < 6 &&_phoneController.text.isEmpty ){
                  print("Please insert all the fields");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Please insert all the fields'),
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
                    return;
                }
                if(_nameController.text.isEmpty){
                  print("Username cannot be empty");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Username cannot be empty'),
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
                    return;
                }
                if(_nameController.text.toLowerCase() == 'admin' || _nameController.text.toLowerCase() == 'superadmin'){
                  print("User cannot name admin");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('User cannot name admin'),
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
                    return;
                }
                if (!_emailController.text.contains('@')) {
                    print("Please enter a valid email");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Invalid email'),
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
                    return;
                }
                if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
                    print("Password must be at least 6 characters long");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Invalid password'),
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
                    return;
                  }
                  if (!isValidPhoneNumber(cleanedPhoneNumber)) {
                    print("Invalid Phone Format");
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Invalid Phone Format'),
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
                    return;
                  }
                  

                _register();
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: const Center(
                  child: Text(
                    'Register',
                    style: TextStyle(fontSize: 18.0),
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
