import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Padding(
            padding: EdgeInsets.only(right: 55.0),
            child: Text('Food Order'),
          )),
        )),
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(255, 129, 18, 18),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
           // Inside the ListView.builder
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              // Check if user's name is "admin", if yes, skip rendering
              if (user['name'] == "admin") {
                return const SizedBox(); // Return an empty SizedBox to skip rendering
              }

              final userOrder = user.reference.collection('order').orderBy('orderDate', descending: true).snapshots();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      user['name'], // Assuming 'name' is a field in your user document
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  StreamBuilder(
                    stream: userOrder,
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final orders = snapshot.data!.docs;
                      return Column(
                        children: orders.map((order) {
                          final orderDate = order['orderDate'] != null
                              ? DateFormat('yyyy-MM-dd').format((order['orderDate'] as Timestamp).toDate())
                              : 'Not Available';
                          final orderTime = _formatDate(order['orderDate']);
                          //final status = order['status'];
                          final foodItems = order.reference.collection('food').snapshots();
                          final notes = order.reference.collection('notes').snapshots();

                          return StreamBuilder(
                            stream: foodItems,
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final foodDocs = snapshot.data!.docs;
                              if (foodDocs.isEmpty || _checkAllZeroQuantity(foodDocs)) {
                                // If no food items or all items have quantity 0, hide the order
                                return Container();
                              } else {
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Date: $orderDate \n$orderTime\n'),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () async {
                                              //_updateStatus(order.reference, 'Cooking');
                                              try {
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
                                                    'title': 'DJU CAFE',
                                                    'body': '${user['name']} \nCooking', // Concatenate additional text after the body
                                                  },
                                                  "notification": <String, dynamic>{
                                                    'title': 'DJU CAFE',
                                                    'body': '${user['name']} \nCooking', // Concatenate additional text after the body
                                                  },
                                                  'to': user['fcmToken'].toString(),
                                                },

                                              ),
                                            );
                                          } catch (e) {
                                            if (kDebugMode) {
                                              print("error push notification");
                                            }
                                          }
                                            },
                                            child: const Text('Cooking'),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () async {
                                              //_updateStatus(order.reference, 'Preparing');
                                              try {
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
                                                    'title': 'DJU CAFE',
                                                    'body': '${user['name']} \nPreparing', // Concatenate additional text after the body
                                                  },
                                                  "notification": <String, dynamic>{
                                                    'title': 'DJU CAFE',
                                                    'body': '${user['name']} \nPreparing', // Concatenate additional text after the body
                                                  },
                                                  'to': user['fcmToken'].toString(),
                                                },

                                              ),
                                            );
                                          } catch (e) {
                                            if (kDebugMode) {
                                              print("error push notification");
                                            }
                                          }
                                            },
                                            child: const Text('Preparing'),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: foodDocs.map((foodDoc) {
                                          final foodName = foodDoc['foodName'];
                                          final foodQuantity = foodDoc['quantity'];
                                          final foodprice = foodDoc['price'];
                                          if (foodQuantity == 0) {
                                            return Container(); // Hide food item if quantity is 0
                                          } else {
                                            return Text('Food: $foodName\nQuantity: $foodQuantity\n Price: $foodprice');
                                          }
                                        }).toList(),
                                      ),
                                      const SizedBox(height: 10),
                                      const Text(
                                        'Notes:',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      StreamBuilder(
                                        stream: notes,
                                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                          if (!snapshot.hasData) {
                                            return const Center(
                                              child: CircularProgressIndicator(),
                                            );
                                          }
                                          final noteDocs = snapshot.data!.docs;
                                          return Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: noteDocs.map((noteDoc) {
                                              final noteText = noteDoc['FoodNote'];
                                              return Text('- $noteText');
                                            }).toList(),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                );
              },

          );
        },
      ),
    );
  }
}
/*Future<void> _updateStatus(DocumentReference reservationRef, String newStatus) async {
    await reservationRef.set({'status': newStatus}, SetOptions(merge: true))
                      .then((value) => print("Okay"))
                      .catchError((error) => print("Failed: $error"));
  }*/
String _formatDate(Timestamp? date) {
  if (date != null) {
    DateTime dateTime = date.toDate();
    String formattedDate =
        "Time ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}.${dateTime.second.toString().padLeft(2, '0')}";
    return formattedDate;
  } else {
    return 'N/A'; // Return a default value or handle it as per your requirement
  }
}

bool _checkAllZeroQuantity(List<QueryDocumentSnapshot> foodDocs) {
  for (var doc in foodDocs) {
    if (doc['quantity'] != 0) {
      return false;
    }
  }
  return true;
}
