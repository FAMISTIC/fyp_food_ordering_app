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
      appBar: AppBar(
        foregroundColor: const Color.fromARGB(224, 234, 47, 13),
        shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Login', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, color:  Color.fromARGB(224, 234, 47, 13))),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email', 
                hintText: 'email@gmail.com',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.email, color: Color.fromARGB(224, 234, 47, 13)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // For rounded corners
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Default border color
                    width: 1, // Border width
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Border color when the field is not focused
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(224, 234, 47, 13), // Border color when the field is focused
                    width: 2, // Border width when focused
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration:  InputDecoration(
                labelText: 'Password',
                hintText: '********',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // For rounded corners
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Default border color
                    width: 1, // Border width
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Border color when the field is not focused
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(224, 234, 47, 13), // Border color when the field is focused
                    width: 2, // Border width when focused
                  ),
                ),
                prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(224, 234, 47, 13)),
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
                          content: const Text('Invalid email or password'),
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
                          content: const Text('Invalid email or password'),
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
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Invalid email or password'),
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
              },
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(225,245, 93, 66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: const Center(
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(fontSize: 15.0, color: Colors.black),),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrationPage()),
                        );
                      },
                      child: const Text(
                        "Register Here",
                        style: TextStyle(fontSize: 15.0, color: Color.fromARGB(225, 245, 93, 66)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 50),
            const Text('Or sign up with', style: TextStyle(color: Colors.black),),
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
                primary: const Color.fromARGB(225,245, 93, 66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    // decoration: BoxDecoration(color: Colors.blue),
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: Colors.white, // Change to desired background color
                        shape: BoxShape.circle,
                      ),
                      child:
                      ClipOval(
                        child: Image.asset(
                            'images/google.png',
                            fit:BoxFit.cover
                        ),
                      )                  
                  ),
                  const SizedBox(width: 8),
                  const Text('Sign-in with Google',  style: TextStyle(fontSize: 18.0, color: Colors.white),)
                ],
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