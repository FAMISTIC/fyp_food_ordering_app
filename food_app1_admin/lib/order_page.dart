import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPage extends StatelessWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Page'),
      ),
      body: OrderList(),
    );
  }
}

class OrderList extends StatelessWidget {
  const OrderList({Key? key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        var users = snapshot.data!.docs;

        // Exclude users with the name 'admin'
        var filteredUsers = users.where((user) => user['name'] != 'admin').toList();

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            var user = filteredUsers[index];

            // Retrieve orders for the current user
            var orders = user.reference.collection('order').snapshots();

            return StreamBuilder<QuerySnapshot>(
              stream: orders,
              builder: (context, orderSnapshot) {
                if (!orderSnapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                var userOrders = orderSnapshot.data!.docs;

                // Check if the user has any orders
                if (userOrders.isEmpty) {
                  return Container(); // Return an empty container to hide the user without orders
                }

                return ListTile(
                  title: Text('User: ${user['name']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var order in userOrders)
                        Text(' - Order Date  : ${_formatDate(order['checkOutDate'])}'),
                      for (var order in userOrders)
                        Text(' - Order Date  : ${_formatDate(order['orderDate'])}'),
                      for (var order in userOrders)
                        Text(' - Table No    : ${order['tableNo']}'),
                      for (var order in userOrders)
                        Text(' - Total Amount: ${order['totalAmount']}'),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

String _formatDate(Timestamp date) {
  // Assuming 'orderDate' is a Timestamp type
  DateTime dateTime = date.toDate();
  String formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  return formattedDate;
}
