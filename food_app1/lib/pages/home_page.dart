// ignore_for_file: library_private_types_in_public_api, prefer_const_literals_to_create_immutables, non_constant_identifier_names

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/components/nav-drawer.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/pages/add_to_cart.dart';

enum UserUpdateResult { success, error }


class HomePage extends StatefulWidget {
  final AppUser user;

  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin{
  late AppUser _updatedUser;

  void closeAppUsingExit() {
    exit(0);
  }

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails();
    _searchController = TextEditingController();
  }

  String searchQuery = '';

  void search() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 1,
      length: 4,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('foods').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in HomePage');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
      
          List<Map<String, dynamic>> firebaseData = [];
      
          snapshot.data?.docs.forEach((DocumentSnapshot documentSnapshot) {
            Map<String, dynamic> foodData =
                documentSnapshot.data() as Map<String, dynamic>;
            String id = documentSnapshot.id;
            foodData['id'] = id;
            firebaseData.add(foodData);
          });
      
          final List filteredData = firebaseData
              .where((item) =>
                  item['name'].toLowerCase().contains(searchQuery) ||
                  item['price'].toString().contains(searchQuery))
              .toList();
      
          return WillPopScope(
            onWillPop: () async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Exit App'),
                  content: const Text('Do you want to exit the App?'),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('No'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                        closeAppUsingExit();
                      },
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              ) ??
                  false;
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Home Page'),
                actions: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CartPage(userId: _updatedUser.uid),
                        ),
                      );
                    },
                    icon: const Icon(Icons.fastfood),
                  ),
                ],
              ),
              drawer: NavDrawer(user: _updatedUser),
              body: 
                Column(
  children: [
    SizedBox(
  height: 50,
  child: ListView(
    scrollDirection: Axis.horizontal,
    children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(2), // Adjust the spacing as needed
        child: ElevatedButton(
          onPressed: () {
            // Handle button tap for Item 1
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Center(
            child: Text(
              'Roti',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(2),// Adjust the spacing as needed
        child: ElevatedButton(
          onPressed: () {
            // Handle button tap for Item 2
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Center(
            child: Text(
              'Nasi',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(2), // Adjust the spacing as needed
        child: ElevatedButton(
          onPressed: () {
            // Handle button tap for Item 3
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Center(
            child: Text(
              'Minum',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
          onPressed: () {
            // Handle button tap for Item 4
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          child: const Center(
            child: Text(
              'Lauk',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    ],
  ),
),

    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: TextField(
            controller: _searchController,
            onSubmitted: (value) => search(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              hintText: "Search here..",
              prefixIcon: const Icon(
                Icons.search,
                color: Colors.grey,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        for (var i = 0; i < filteredData.length; i++) ...[
          GestureDetector(
            onTap: () {
              _AddToCart(filteredData[i], _updatedUser.uid);
            },
            child: Container(
              width: 400,
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 21, 180, 26),
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        filteredData[i]['imagePath'],
                        height: 100,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            filteredData[i]['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'RM ${filteredData[i]['price'].toString()}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color.fromARGB(255, 255, 255, 255),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ],
    ),
  ],
),

            ),
          );
        },
      ),
    );
  }
  // Add this function inside your _HomePageState class
Future<String> _getUserOrderId(String userId) async {
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

  Future<void> _AddToCart(Map<String, dynamic> foodData, String userId) async {
    TextEditingController quantityController = TextEditingController();
    int quantity = 1;

    await showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add to Cart',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    foodData['description'],
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 16.0),
                  Row(
                    children: [
                      const Text(
                        'Quantity:',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(width: 16.0),
                      SizedBox(
                        width: 50.0,
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              quantity = int.tryParse(value) ?? 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      String orderId = await _getUserOrderId(userId);

                      Map<String, dynamic> orderData = {
                        'orderDate': DateTime.now(),
                      };

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('order')
                          .doc(orderId)
                          .set(orderData);

                      String foodId =
                          DateTime.now().millisecondsSinceEpoch.toString();
                      Map<String, dynamic> cartItem = {
                        'foodId': foodId,
                        'foodName': foodData['name'],
                        'quantity': quantity,
                        'price': foodData['price'],
                      };

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(userId)
                          .collection('order')
                          .doc(orderId)
                          .collection('food')
                          .add(cartItem);

                     /* ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to Cart successfully'),
                        ),
                      );*/
                    },
                    child: const Text('Add to Cart'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

