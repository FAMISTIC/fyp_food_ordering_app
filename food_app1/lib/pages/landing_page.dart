import 'package:flutter/material.dart';
import 'package:food_app1/pages/login_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.restaurant,
              size: 100,
              color:  Color.fromARGB(225,245, 93, 66),
            ),
            const SizedBox(height: 20),
            const Text(
              "Welcome to DJU Cafe!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Discover delicious recipes, find the best restaurants, and explore culinary delights from around the world.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30), // Additional space before the button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(225,245, 93, 66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: const Center(
                  child: Text(
                    'Go to Login',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
              ), // Text on the button
            ),
          ],
        ),
      ),
    );
  }
}