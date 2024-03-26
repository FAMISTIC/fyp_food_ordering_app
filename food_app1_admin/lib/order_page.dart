import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

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
        title: const Text('Food Orders'),
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
            itemBuilder: (BuildContext context, int index) {
              final user = users[index];
              final userOrder = user.reference.collection('order').snapshots();

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
                          final foodItems = order.reference.collection('food').snapshots();
                          final notes = order.reference.collection('notes').snapshots();

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
                                Text('Date: $orderDate \n$orderTime'),
                                StreamBuilder(
                                  stream: foodItems,
                                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (!snapshot.hasData) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    }
                                    final foodDocs = snapshot.data!.docs;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: foodDocs.map((foodDoc) {
                                        final foodName = foodDoc['foodName'];
                                        final foodQuantity = foodDoc['quantity'];
                                        final foodprice = foodDoc['price'];
                                        return Text('Food: $foodName\nQuantity: $foodQuantity\n Price: $foodprice');
                                      }).toList(),
                                    );
                                  },
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
