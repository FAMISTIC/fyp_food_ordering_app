import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:food_app1/pages/login_page.dart';
import 'controllers/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
