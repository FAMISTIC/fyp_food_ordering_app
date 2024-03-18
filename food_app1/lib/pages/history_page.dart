// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/models/user_model.dart';

class HistoryPage extends StatefulWidget {
  final AppUser user;

  const HistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late AppUser _updatedUser;

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_updatedUser.uid)
            .collection('order')
            .orderBy('orderDate', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Error fetching orders');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          List<DocumentSnapshot> orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Text('No orders found.'),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> orderData = orders[index].data() as Map<String, dynamic>;
              String orderId = orders[index].id;
              
              // Check if checkout date, table no, and total amount are all null
              if (orderData['checkOutDate'] == null &&
                  orderData['tableNo'] == null &&
                  orderData['totalAmount'] == null) {
                // Hide the order if all details are null
                return const SizedBox.shrink();
              }

              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Order ID: $orderId'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (orderData['checkOutDate'] != null)
                        Text('Check-Out Date: ${_formatDate(orderData['checkOutDate'])}'),
                      if (orderData['tableNo'] != null)
                        Text('Table No: ${orderData['tableNo']}'),
                      if (orderData['totalAmount'] != null)
                        Text('Total Amount: RM ${orderData['totalAmount']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
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
String _formatDate(Timestamp? date) {
  if (date != null) {
    DateTime dateTime = date.toDate();
    String formattedDate =
        "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    return formattedDate;
  } else {
    return 'N/A'; // Return a default value or handle it as per your requirement
  }
}

