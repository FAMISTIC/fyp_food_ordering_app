// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class PushNotificationPage extends StatefulWidget {
  const PushNotificationPage({super.key});

  @override
  _PushNotificationPageState createState() => _PushNotificationPageState();
}

class _PushNotificationPageState extends State<PushNotificationPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    // Initialize Firebase Messaging
    _firebaseMessaging.getToken().then((token) {
      print('Token: $token');
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });

  }


  Future<void> sendPushMessage() async {
    try{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=AAAAfstLWrA:APA91bGlTPTuyr5GLBRnz7xH2ZqxrG0QEI_SXXnwgxGBFADCpEOujreIuBk7Lcv3wzlqlgf8vdUzMX__rhgsj3H5Mc_eUPi0l9VuMBycdfzihxTXIeErNKQZ0lbbQ2bBKZ5UYFcYKUPO',
        },
        body: jsonEncode(
          <String, dynamic>{
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status' : 'done',
              'body' : 'DJU CAFE',
              'title' : 'TESTING',
            },
            "notification" : <String, dynamic>{
              'title' : 'DJU CAFE',
              'body' : 'TESTING',
            },
            'to': "fm-HnU4qS5C6a-p7Aqo6zG:APA91bHxtIML_5T6D9Nthps9oIp1fJpXjXyE6ohrg0sd8fBre4_T3oXhlFnWJpzzCAZloJCqgkKND5PWjx9i9P4YIB9BMfo1DIQhwEkXUT9gzjQ_fG-XEQyNUr5O8Y-FzCsIA53kXwnR"
          }
        )
      );
    } catch (e){
        if  (kDebugMode){
            print("error push notification");
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification Button'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {sendPushMessage();},
          child: const Text('Send Push Notification'),
        ),
      ),
    );
  }
  
  
}
