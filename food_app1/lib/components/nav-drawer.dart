import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/pages/home_page.dart';
import 'package:food_app1/pages/login_page.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/pages/user_profile_page.dart';
import 'package:google_sign_in/google_sign_in.dart';


class NavDrawer extends StatefulWidget {
  final AppUser user;

  const NavDrawer({super.key, required this.user});

  @override
  _NavDrawerState createState() => _NavDrawerState();
}


class _NavDrawerState extends State<NavDrawer>{

  late AppUser _updatedUser;

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails(); // Fetch user details when the page is loaded
  }
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 64,
            backgroundImage: NetworkImage(_updatedUser.imageLink),),
            const SizedBox(height: 20),
          Text(_updatedUser.name),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('History'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About Dju'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.verified_user),
            title: const Text('My Account'),
            onTap: () async {
            final result = await Navigator.push<UserUpdateResult>(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfilePage(user: _updatedUser),
              ),
            );

            // Fetch the latest user details again if the result is success
            if (result == UserUpdateResult.success) {
              await _fetchUserDetails();
            }
          },
          ),
          ListTile(
            leading: const Icon(Icons.table_restaurant),
            title: const Text('Table Reservation'),
            onTap: () => {Navigator.of(context).pop()},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Logout'),
            onTap: () => {
            GoogleSignIn().signOut(),
            FirebaseAuth.instance.signOut().then((value){
              print("Signed Out");
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => const LoginPage()));
            }),},
          ),
        ],
      ),
    );
  }
  Future<void> _fetchUserDetails() async {
    AppUser? userDetails =
        await FirebaseAuthService().getUserDetails(widget.user.uid);

    if (userDetails != null) {
      // Update the state with the new user details
      setState(() {
        _updatedUser = userDetails;
      });
    } else {
      // Show error message if user details couldn't be fetched
      print("Error fetching user details.");
    }
  }
}