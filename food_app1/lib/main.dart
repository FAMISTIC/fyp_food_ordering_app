import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:food_app1/controllers/firebase_options.dart';
import 'package:food_app1/pages/landing_page.dart';
import 'package:food_app1/pages/push_notification_page.dart';
import 'package:provider/provider.dart';
import 'package:firebase_app_check/firebase_app_check.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'foodapp1-9dc11',
    options: DefaultFirebaseOptions.currentPlatform,
    
  );
  Stripe.publishableKey = 'pk_live_51Ph2O4H5T8AU6G4VKPzIVNZYiG7WQOeTMjryMMMC9YEa8QjKJRCmFYOFxWcYDOxPa9XnGEdP94wHNrB9DuiAbDp600I8JshiAV';
  await dotenv.load(fileName: "assets/.env");
 await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
        // your preferred provider. Choose from:
        // 1. Debug provider
        // 2. Device Check provider
        // 3. App Attest provider
        // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  AwesomeNotifications().initialize(
    null,
    [
      NotificationChannel(
        channelKey: 'basic_channel', 
        channelName: 'Basic notification', 
        channelDescription: 'Notification channel for basic tests'),
    ],
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((token) {
      print("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received message: ${message.notification?.title}");
      print("Received message: ${message.notification?.body}");
    });
  }
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PushNotificationState(),
      child: MaterialApp(
        title: 'Dju Cafe',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const LandingPage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
 Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
       print("Handling a background message");
 } 