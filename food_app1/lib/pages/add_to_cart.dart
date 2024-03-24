// ignore_for_file: use_build_context_synchronously, must_be_immutable, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/pages/receipt_page.dart';

class CartPage extends StatefulWidget {
  final String userId;
  final String newOrderId;

  const CartPage({Key? key, required this.userId,required this.newOrderId}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double totalAmount = 0;
  int selectedTableNo = 1;
  TextEditingController _noteController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: FutureBuilder<String?>(
        future: _getUserOrderId(widget.userId),
        builder: (BuildContext context, AsyncSnapshot<String?> orderIdSnapshot) {
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
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error'),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No items in the cart'),
                );
              }

              totalAmount = 0;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          Map<String, dynamic>? foodItem = document.data() as Map<String, dynamic>;

                          totalAmount += foodItem['quantity'] *
                              double.parse(foodItem['price'].toString());

                          return ListTile(
                            title: Text('${foodItem['foodName']}'),
                            subtitle: Text(
                              'Quantity: ${foodItem['quantity']}   '
                              'RM${(foodItem['quantity'] * double.parse(foodItem['price'].toString())).toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    _updateQuantity(
                                        orderId, document.id, foodItem['quantity'] + 1);
                                  },
                                  icon: const Icon(Icons.add),
                                ),
                                IconButton(
                                  onPressed: () {
                                    if (foodItem['quantity'] > 1) {
                                      _updateQuantity(
                                          orderId, document.id, foodItem['quantity'] - 1);
                                    } else {
                                      _removeItem(orderId, document.id);
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _removeItem(orderId, document.id);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<int>(
                      value: selectedTableNo,
                      items: List.generate(10, (index) {
                        return DropdownMenuItem<int>(
                          value: index + 1,
                          child: Text('Table ${index + 1}'),
                        );
                      }),
                      onChanged: (int? value) {
                        if (value != null) {
                          setState(() {
                            selectedTableNo = value;
                          });
                        }
                      },
                      hint: const Text('Select Table'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Overall Total: \$${totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              String orderId = await _getUserOrderId(widget.userId) ?? '';

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(widget.userId)
                  .collection('order')
                  .doc(orderId)
                  .update({
                'orderDate': DateTime.now(),
                'checkOutDate': DateTime.now(),
                'totalAmount': totalAmount,
                'tableNo': selectedTableNo,
                'note': _noteController.text,
              });

              // Get the new order ID after updating
              String newOrderId = await _getUserOrderId(widget.userId) ?? '';

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReceiptPage(userId: widget.userId, orderIdFuture: Future.value(newOrderId), totalAmount: totalAmount),
                ),
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checkout successful'),
                ),
              );
            },
            child: const Text('Checkout'),
          ),

        ),
      ),
    );
  }

Future<String?> _getUserOrderId(String userId) async {
  var orderSnapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('order')
      .orderBy('orderDate', descending: true) // Order by orderDate descending
      .limit(1)
      .get();

  if (orderSnapshot.docs.isNotEmpty) {
    return orderSnapshot.docs.first.id;
  } else {
    var newOrderRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('order')
        .add({'orderDate': DateTime.now()});

    // Wait for the new order to be created and return its ID
    return newOrderRef.id;
  }
}




  void _updateQuantity(String orderId, String foodId, int newQuantity) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('order')
        .doc(orderId)
        .collection('food')
        .doc(foodId)
        .update({'quantity': newQuantity});
  }

  void _removeItem(String orderId, String foodId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId)
        .collection('order')
        .doc(orderId)
        .collection('food')
        .doc(foodId)
        .delete();
  }
}
