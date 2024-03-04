import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'controllers/firebase_options.dart'; // Ensure this import is correct
import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Add a constructor to initialize Firebase Messaging
  MyApp({Key? key}) : super(key: key) {
    _configureFirebase();
  }

  // Configure Firebase Messaging
  void _configureFirebase() {
    _firebaseMessaging.getToken().then((String? token) {
      print('FCM Token: $token');
      // You can save the token or send it to your server for later use.
    });

    // Handle incoming messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received message: ${message.notification?.title}');
      // Handle the message here
    });

    // Handle when the app is in the background and opened by tapping the notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app from background message: ${message.notification?.title}');
      // Handle the message here
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dju Cafe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
