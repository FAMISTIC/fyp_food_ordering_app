// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/pages/home_page.dart';
import 'package:food_app1/pages/reset_password_page.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/pages/registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16.0),

            forgetPassword(context),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: () async {
                
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
                User? user = await FirebaseAuthService().signInWithEmailAndPassword(
                  _emailController.text,
                  _passwordController.text,
                );

                if (user != null) {
                  // Fetch user details from Firestore
                  AppUser? userDetails = await FirebaseAuthService().getUserDetails(user.uid);

                  if (userDetails != null) {
                    // Navigate to the home page with actual user details
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(user: userDetails)),
                    );
                  } else {
                    // Show error message if user details couldn't be fetched
                    print("Error fetching user details.");
                  }
                } else {
                  // Show login error message
                  print("Login failed.");
                }
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
                    'Login',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {

                User? user = await FirebaseAuthService().signInWithGoogle();

                if (user != null) {
                  // Fetch user details from Firestore
                  AppUser? userDetails = await FirebaseAuthService().getUserDetails(user.uid);

                  if (userDetails != null) {
                    // Navigate to the home page with actual user details
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage(user: userDetails)),
                    );
                  } else {
                    // Show error message if user details couldn't be fetched
                    print("Error fetching user details.");
                    
                    
                  }
                } else {
                  // Show login error message
                  print("Google Sign-In failed.");
                  
                }
                
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
                    'Sign in with Google',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
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
  Widget forgetPassword(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 35,
      alignment: Alignment.bottomRight,
      child: TextButton(
        child: const Text(
          "Forgot Password?",
          style: TextStyle(color: Color.fromARGB(179, 0, 0, 0)),
          textAlign: TextAlign.right,
        ),
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (context) => const ResetPassword())),
      ),
    );
  }
}