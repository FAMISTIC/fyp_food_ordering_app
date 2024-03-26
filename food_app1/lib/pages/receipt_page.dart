// ignore_for_file: use_build_context_synchronously, prefer_adjacent_string_concatenation, prefer_interpolation_to_compose_strings
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/pages/home_page.dart';
import 'package:food_app1/pages/push_notification_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

// ... (existing imports)

class ReceiptPage extends StatefulWidget {
  final String userId;
  final Future<String?> orderIdFuture;
  final double totalAmount;

  const ReceiptPage({
    Key? key,
    required this.userId,
    required this.orderIdFuture,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final NotificationManager _notificationManager = NotificationManager();

  @override
  void initState(){
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
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
              'title' : 'Order Received',
            },
            "notification" : <String, dynamic>{
              'title' : 'DJU CAFE',
              'body' : 'Order Received',
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
    var pushNotificationState = Provider.of<PushNotificationState>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: FutureBuilder<String?>(
        future: widget.orderIdFuture,
        builder: (context, orderIdSnapshot) {
          if (orderIdSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (orderIdSnapshot.hasError || orderIdSnapshot.data == null) {
            return const Center(
              child: Text('Error fetching order details'),
            );
          }

          String orderId = orderIdSnapshot.data!;

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(widget.userId)
                .collection('order')
                .doc(orderId)
                .collection('food')
                .snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> foodSnapshot) {
              if (foodSnapshot.hasError) {
                return const Center(
                  child: Text('Error'),
                );
              }

              if (foodSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (foodSnapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No items in the cart'),
                );
              }

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(widget.userId)
                    .collection('order')
                    .doc(orderId)
                    .get(),
                builder: (context, orderInfoSnapshot) {
                  if (orderInfoSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (orderInfoSnapshot.hasError || !orderInfoSnapshot.hasData) {
                    return const Center(
                      child: Text('Error fetching order information'),
                    );
                  }

                  int tableNo = orderInfoSnapshot.data!['tableNo'] ?? 1;

                  // Fetch note document
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.userId)
                        .collection('order')
                        .doc(orderId)
                        .collection('notes')
                        .limit(1) // Limit to 1 document
                        .get()
                        .then((value) => value.docs.first),
                    builder: (context, noteSnapshot) {
                      if (noteSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!noteSnapshot.hasData || noteSnapshot.data == null) {
                        // If note document doesn't exist or there's no data
                        return const SizedBox(); // Just return an empty container or nothing
                      }

                      String note = noteSnapshot.data!['FoodNote'] ?? '';

                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Receipt Details',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'User ID: ${widget.userId}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            // Display other details...
                            const SizedBox(height: 16),
                            Text(
                              'Table No: $tableNo',
                              style: const TextStyle(fontSize: 16),
                            ),
                            // Display other details...
                            const SizedBox(height: 16),
                            if (note.isNotEmpty) // Check if note is not empty
                              Text(
                                'Note: $note', // Display the note
                                style: const TextStyle(fontSize: 16),
                              ),
                            // Display other details...
                            const SizedBox(height: 16),
                            const Text(
                              'Items Purchased:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 200, // Adjust the height as needed
                              child: ListView(
                                children: foodSnapshot.data!.docs.map(
                                  (DocumentSnapshot document) {
                                    Map<String, dynamic>? foodItem = document.data() as Map<String, dynamic>;

                                    return ListTile(
                                      title: Text('${foodItem['foodName']}'),
                                      subtitle: Text(
                                        'Quantity: ${foodItem['quantity']}   '
                                        'RM${(foodItem['quantity'] * double.parse(foodItem['price'].toString())).toStringAsFixed(2)}',
                                      ),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Total Amount: RM${widget.totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text(
                            'Your order will be sent to the kitchen. Kindly pay ' +
                                'RM${widget.totalAmount.toStringAsFixed(2)} ' +
                                'at the counter to proceed with your order.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                                                    const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            sendPushMessage();
                            if (pushNotificationState.pushNotificationEnabled) {
                              // sendPushMessage();
                              _notificationManager.triggerNotification();
                            }
                                                  
                            String newOrderId = await _createNewOrder(widget.userId);

                            // Create a temporary AppUser instance with only userId
                            AppUser temporaryUser = AppUser(uid: widget.userId, email: "", name: "", phone: 0, imageLink: "");

                            // Navigate to the HomePage with the temporary AppUser instance
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(
                                  user: temporaryUser
                                ),
                              ),
                            );
                          },
                          child: const Text('Confirm Order'),
                        ),

                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<String> _createNewOrder(String userId) async {
    // Create a new order document under the 'order' collection
    DocumentReference newOrderRef =
        await FirebaseFirestore.instance.collection('users').doc(userId).collection('order').add({
      'orderDate': DateTime.now(),
      'checkOutDate': null,
      'totalAmount': 0,
      'tableNo': 0,
    });

    // Return the ID of the newly created order
    return newOrderRef.id;
  }
}
