// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatefulWidget{
  final AppUser user;

  const FeedbackPage({Key? key, required this.user}) : super(key: key);

  @override
  _FeedbackPageState createState() => _FeedbackPageState();
  
}

class _FeedbackPageState extends State<FeedbackPage> {
  late AppUser _updatedUser;
  
  final TextEditingController _feedbackController = TextEditingController();
 @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails();
  }

void _submitFeedback() {
  String feedback = _feedbackController.text;
  if (feedback.isNotEmpty) {
    // Get reference to the 'users' collection
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    // Add a new document with a generated ID to the 'feedback' collection inside the user's document
    users.doc(_updatedUser.uid).collection('feedback').add({
      'feedbacknote': feedback,
      'timestamp': DateTime.now(),
    }).then((_) {
      // Clear the text field after successful submission
      _feedbackController.clear();
      // Show a confirmation dialog or message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Feedback Submitted'),
            content: const Text('Thank you for your feedback!'),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }).catchError((error) {
      // Handle errors if any
      print('Failed to submit feedback: $error');
    });
  } else {
    // Show an error message if feedback is empty
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter your feedback.'),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _feedbackController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              child: const Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _fetchUserDetails() async {
    AppUser? userDetails =
        await FirebaseAuthService().getUserDetails(widget.user.uid);

    if (userDetails != null) {
      setState(() {
        _updatedUser = userDetails;
      });
    } else {
      print("Error fetching user details.");
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}