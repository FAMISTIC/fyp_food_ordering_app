import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptPage extends StatelessWidget {
  final String userId;
  final String orderId;

  const ReceiptPage({Key? key, required this.userId, required this.orderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('order')
            .doc(orderId)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError || !snapshot.hasData) {
            print('Error fetching order details: ${snapshot.error}');
            return const Center(
              child: Text('Error fetching order details'),
            );
          }

          Map<String, dynamic>? orderData =
              snapshot.data!.data() as Map<String, dynamic>?;

          if (orderData == null) {
            print('Order data is null');
            return const Center(
              child: Text('Error: Order data is null'),
            );
          }

          print('Order Data: $orderData');

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order Date: ${orderData['orderDate']}'),
                const SizedBox(height: 16.0),
                Text('Order ID: $orderId'),
                const SizedBox(height: 16.0),
                Text('Items:'),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(userId)
                        .collection('order')
                        .doc(orderId)
                        .collection('food')
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        print('Error fetching order items: ${snapshot.error}');
                        return const Center(
                          child: Text('Error fetching order items'),
                        );
                      }

                      return ListView(
                        children: snapshot.data!.docs.map(
                          (DocumentSnapshot document) {
                            Map<String, dynamic>? foodItem =
                                document.data() as Map<String, dynamic>?;

                            if (foodItem == null) {
                              print('Food item is null, skipping...');
                              return const SizedBox.shrink(); // Skip null items
                            }

                            return ListTile(
                              title: Text('${foodItem['foodName']}'),
                              subtitle: Text(
                                'Quantity: ${foodItem['quantity']}   '
                                'RM${(foodItem['quantity'] * double.parse(foodItem['price'].toString())).toStringAsFixed(2)}',
                              ),
                            );
                          },
                        ).toList(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Total Amount: RM${orderData['totalAmount'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
