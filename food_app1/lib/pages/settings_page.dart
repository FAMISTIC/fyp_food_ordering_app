// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/pages/feedback_page.dart';
import 'package:food_app1/pages/login_page.dart';
import 'package:food_app1/pages/push_notification_page.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SettingsPage extends StatefulWidget {
  final AppUser user;
  const SettingsPage({Key? key, required this.user}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late AppUser _updatedUser;

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails();
  }

  Future <void> logout()async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                GoogleSignIn().signOut();
                  FirebaseAuth.instance.signOut().then((value) {
                    print("Signed Out");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  });
              },
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(225, 245, 93, 66),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        title: const Center(
          child: Padding(
            padding: EdgeInsets.only(right: 55),
            child: Text('Settings'),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: ListTile(
                leading: const Icon(Icons.feedback,
                    color: Color.fromARGB(225, 245, 93, 66)),
                title: const Text(
                  'Feedback',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FeedbackPage(user: _updatedUser),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: ListTile(
                leading: const Icon(Icons.notifications,
                    color: Color.fromARGB(225, 245, 93, 66)),
                title: const Text(
                  'Push Notifications',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PushNotificationPage(user: _updatedUser)),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Account Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: ListTile(
                leading: const Icon(Icons.logout,
                    color: Color.fromARGB(225, 245, 93, 66)),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: () => {
                  logout(),
                },
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              child: ListTile(
                leading: const Icon(Icons.delete,
                    color: Color.fromARGB(225, 245, 93, 66)),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward),
                onTap: _deleteAccount,
              ),
            ),
            // Add more account settings as needed
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

  Future<void> _deleteAccount() async {
  // Show confirmation dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Confirm Delete Account"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Delete user account from Firebase Authentication
                await FirebaseAuth.instance.currentUser?.delete();

                // Delete user details from Firestore collection
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.user.uid)
                    .delete();

                print("User account and details deleted");
                
                // Navigate to login page after successful deletion
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              } catch (e) {
                print("Error deleting user account: $e");
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error deleting account: $e")),
                );
              }
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}

}
