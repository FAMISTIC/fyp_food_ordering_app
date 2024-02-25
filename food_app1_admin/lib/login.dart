// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_app1_admin/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                // Add Firebase Authentication logic here
                String email = _emailController.text;
                String password = _passwordController.text;

                try {
                  UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );

                  // Successful login, navigate to HomePage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                } on FirebaseAuthException catch (e) {
                  // Failed login, show an error message
                  print('Error: ${e.message}');
                }
              },
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}