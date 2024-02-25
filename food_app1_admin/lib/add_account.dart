// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_app1_admin/constraints/textfield.dart';
import 'package:flutter/material.dart';
import 'package:food_app1_admin/FirebaseAuthService.dart';
import 'package:food_app1_admin/user_account.dart';


class AddPage extends StatefulWidget {
  const AddPage({Key? key}) : super(key: key);

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {

  //form key
  final _formkey = GlobalKey<FormState>();
  // text for textfield

  // textfield
   TextEditingController nameController = TextEditingController();
   TextEditingController phoneController = TextEditingController();
   TextEditingController passwordController = TextEditingController();
   TextEditingController emailController = TextEditingController();
  //Clearing Text
  _clearText() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    passwordController.clear();
  }
 
  //Resigtering Users
  Future<void> _register() async {
    try {
      User? user = await FirebaseAuthService().registerWithEmailAndPassword(
        emailController.text,
        passwordController.text,
      );

      // Additional user details
      String name = nameController.text;
      int phone = int.tryParse(phoneController.text) ?? 0;
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
        MaterialPageRoute(builder: (context) => const UserPage()),
      );
    } catch (e) {
      // Handle registration errors
      print("Failed to register: $e");
      // You can show a user-friendly message to the user here.
    }
  }

  //Disposing Textfield
  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add'),
      ),
      body: Form(
        key: _formkey,
        child: ListView(
          children: [
            CustomTextEditField(
              controller: nameController,
              labettxt: 'Name',
            ),
            CustomTextEditField(
              controller: emailController,
              labettxt: 'Email',
            ),
            CustomTextEditField(
              controller: passwordController,
              labettxt: 'Password',
            ),
            CustomTextEditField(
              controller: phoneController,
              labettxt: 'Phone',
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_formkey.currentState!.validate()) {
                      setState(() {
                         _register();
                        Navigator.pop(context);
                      });
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  child: const Text('Register'),
                ),
                ElevatedButton(
                  onPressed: _clearText,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}