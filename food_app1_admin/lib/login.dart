// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:food_app1_admin/home.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key});

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
        title: const Center(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Text('DJU CAFE Admin')),
        )),
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(255, 129, 18, 18),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email', 
                hintText: 'email@gmail.com',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 129, 18, 18),),
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
                    color: Color.fromARGB(255, 129, 18, 18), // Border color when the field is not focused
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 129, 18, 18),// Border color when the field is focused
                    width: 2, // Border width when focused
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration:  InputDecoration(
                labelText: 'Password',
                hintText: '********',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // For rounded corners
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 129, 18, 18),// Default border color
                    width: 1, // Border width
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 129, 18, 18), // Border color when the field is not focused
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(255, 129, 18, 18), // Border color when the field is focused
                    width: 2, // Border width when focused
                  ),
                ),
                prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(255, 129, 18, 18),),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 129, 18, 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              onPressed: () async {
                // Add Firebase Authentication logic here
                String email = _emailController.text;
                String password = _passwordController.text;

                if (email == "superadmin@gmail.com") {
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
                } else {
                  // Disallow login for other users
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

          ],
        ),
      ),
    );
  }
}
