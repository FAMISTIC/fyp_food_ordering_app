// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/pages/about_dju.dart';
import 'package:food_app1/pages/home_page.dart';
import 'package:food_app1/pages/login_page.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/pages/settings_page.dart';
import 'package:food_app1/pages/table_reservation_page.dart';
import 'package:food_app1/pages/user_profile_page.dart';
import 'package:food_app1/pages/history_page.dart'; // Import the new HistoryPage
import 'package:google_sign_in/google_sign_in.dart';

class NavDrawer extends StatefulWidget {
  final AppUser user;

  const NavDrawer({super.key, required this.user});

  @override
  _NavDrawerState createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  late AppUser _updatedUser;

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(225, 245, 93, 66),
      child: Drawer(
        backgroundColor: const Color.fromARGB(225, 245, 93, 66),
        shape:  const ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(50),
                topRight: Radius.circular(50)),
              ),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: <Widget>[
            const SizedBox(height: 20),
            CircleAvatar(
              backgroundColor: Colors.white,
              radius: 68,
              child: CircleAvatar(
                radius: 64,
                backgroundImage: NetworkImage(_updatedUser.imageLink),
              ),
            ),
            const SizedBox(height: 20),
            Text(_updatedUser.name, 
            style: const TextStyle(color: Colors.white),),
            const SizedBox(height: 20),
             ListTile(
              leading: const Icon(Icons.settings, color: Colors.white,),
              title: const Text('Settings', 
              style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(user: _updatedUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white,),
              title: const Text('History', 
              style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HistoryPage(user: _updatedUser),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white,),
              title: const Text('About Dju', 
              style: TextStyle(color: Colors.white),),
              onTap: () {
                Navigator.of(context).pop(); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutDjuPage(),
                  ),
                );
              },
            ),
      
            ListTile(
              leading: const Icon(Icons.verified_user, color: Colors.white,),
              title: const Text('My Account', 
              style: TextStyle(color: Colors.white),),
              onTap: () async {
                final result = await Navigator.push<UserUpdateResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(user: _updatedUser),
                  ),
                );
      
                if (result == UserUpdateResult.success) {
                  await _fetchUserDetails();
                }
              },
            ),
            ListTile(
            leading: const Icon(Icons.table_restaurant, color: Colors.white,),
            title: const Text('Table Reservation', 
            style: TextStyle(color: Colors.white),),
            onTap: () {
              Navigator.of(context).pop(); // Close the drawer
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TableReservationPage(user: _updatedUser), // Navigate to TableReservationPage
                ),
              );
            },
          ),
      
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.white,),
              title: const Text('Logout', 
              style: TextStyle(color: Colors.white),),
              onTap: () => {
                GoogleSignIn().signOut(),
                FirebaseAuth.instance.signOut().then((value) {
                  print("Signed Out");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }),
              },
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
}
