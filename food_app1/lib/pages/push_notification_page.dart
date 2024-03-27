// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:provider/provider.dart';

class PushNotificationState with ChangeNotifier {
  
  bool _pushNotificationEnabled = false;

  bool get pushNotificationEnabled => _pushNotificationEnabled;

  void setPushNotificationEnabled(bool value) {
    _pushNotificationEnabled = value;
    notifyListeners(); // Notify listeners of the change
  }
}

class PushNotificationPage extends StatefulWidget {
  final AppUser user;
  const PushNotificationPage({Key? key, required this.user}) : super(key: key);

  @override
  _PushNotificationPageState createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {

  late AppUser _updatedUser;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Instantiate NotificationManager
  final NotificationManager _notificationManager = NotificationManager();
  

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Messaging
    _updatedUser = widget.user;
    _fetchUserDetails();
    _firebaseMessaging.requestPermission();
    _firebaseMessaging.getToken().then((token) {
      print('Token: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification}');
      }
    });
  }

  Future<void> sendPushMessage() async {
    try {
/*
    await FirebaseFirestore.instance.collection('users').doc(_updatedUser.uid).set({
      'fcmToken': token, // Store the FCM token
    }, SetOptions(merge: true))
    .then((value) => print("Token Added"))
    .catchError((error) => print("Failed to add token: $error"));*/
    
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization':
              'key=AAAAfstLWrA:APA91bGlTPTuyr5GLBRnz7xH2ZqxrG0QEI_SXXnwgxGBFADCpEOujreIuBk7Lcv3wzlqlgf8vdUzMX__rhgsj3H5Mc_eUPi0l9VuMBycdfzihxTXIeErNKQZ0lbbQ2bBKZ5UYFcYKUPO',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body': 'DJU CAFE',
              'title': 'TESTING',
            },
            "notification": <String, dynamic>{
              'title': 'DJU CAFE',
              'body': 'TESTING',
            },
            'to':
                "fm-HnU4qS5C6a-p7Aqo6zG:APA91bHxtIML_5T6D9Nthps9oIp1fJpXjXyE6ohrg0sd8fBre4_T3oXhlFnWJpzzCAZloJCqgkKND5PWjx9i9P4YIB9BMfo1DIQhwEkXUT9gzjQ_fG-XEQyNUr5O8Y-FzCsIA53kXwnR"
          },
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print("error push notification");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var pushNotificationState = Provider.of<PushNotificationState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification Button'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                if (pushNotificationState.pushNotificationEnabled) {
                  // sendPushMessage();
                    _firebaseMessaging.getToken().then((String? token) {
                    if (token != null) {
                      FirebaseFirestore.instance.collection('users').doc(_updatedUser.uid).set({
                        'fcmToken': token, // Store the FCM token
                      }, SetOptions(merge: true))
                      .then((value) => print("Token Added"))
                      .catchError((error) => print("Failed to add token: $error"));
                    } else {
                      print("Failed to retrieve FCM token.");
                    }
                  });
                  _notificationManager.triggerNotification();
                }
              },
              child: const Text('Send Push Notification'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Push Notifications:'),
                Switch(
                  value: pushNotificationState.pushNotificationEnabled,
                  onChanged: (value) {
                    pushNotificationState.setPushNotificationEnabled(value);
                  },
                ),
              ],
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

class NotificationManager {
  void triggerNotification() {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
      id: 10,
      channelKey: 'basic_channel',
      title: 'Dju CAFE',
      body: 'Order Sent',
    ));
  }
}
