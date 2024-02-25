// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/pages/receipt_page.dart';

class CartPage extends StatelessWidget {
  final String userId;

  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: FutureBuilder<String?>(
        future: _getUserOrderId(userId),
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
                .doc(userId)
                .collection('order')
                .doc(orderId)
                .collection('food')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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

              double totalAmount = 0;

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: snapshot.data!.docs.map(
                        (DocumentSnapshot document) {
                          Map<String, dynamic>? foodItem =
                              document.data() as Map<String, dynamic> ;

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
                                      // Implement logic to remove the item from the cart
                                      _removeItem(orderId, document.id);
                                    }
                                  },
                                  icon: const Icon(Icons.remove),
                                ),
                                IconButton(
                                  onPressed: () {
                                    // Implement logic to remove the item from the cart
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
              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('order')
                  .doc(await _getUserOrderId(userId))
                  .update({
                'checkOutDate': DateTime.now(),
              });

              // Implement any additional logic for the checkout process here
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReceiptPage(userId: userId, orderId:  _getUserOrderId(userId).toString()),
                ),
              );
              // Show a success message or navigate to a confirmation page
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
        .limit(1)
        .get();

    if (orderSnapshot.docs.isNotEmpty) {
      return orderSnapshot.docs.first.id;
    } else {
      var newOrder = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('order')
          .add({'orderDate': DateTime.now()});

      return newOrder.id;
    }
  }

  void _updateQuantity(String orderId, String foodId, int newQuantity) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('order')
        .doc(orderId)
        .collection('food')
        .doc(foodId)
        .update({'quantity': newQuantity});
  }

  void _removeItem(String orderId, String foodId) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('order')
        .doc(orderId)
        .collection('food')
        .doc(foodId)
        .delete();
  }
}
