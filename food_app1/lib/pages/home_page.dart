// ignore_for_file: library_private_types_in_public_api, prefer_const_literals_to_create_immutables, non_constant_identifier_names, use_build_context_synchronously

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

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AppUser _updatedUser;

  void closeAppUsingExit() {
    exit(0);
  }

  late TextEditingController _searchController;
  Map<String, bool> _favoriteItems = {};

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails();
    _searchController = TextEditingController();
    _initializeFavorites(widget.user.uid); // Initialize favorites
  }

  String searchQuery = '';
  String _selectedFoodType = '';

  void search() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  // Initialize favorites based on Firebase data
  Future<void> _initializeFavorites(String userId) async {
    CollectionReference favoriteCollection =
        FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites');

    QuerySnapshot favoritesSnapshot = await favoriteCollection.get();
    Map<String, bool> favoritesMap = {};

    for (QueryDocumentSnapshot doc in favoritesSnapshot.docs) {
      String foodName = (doc?.data() as Map<String, dynamic>?)?['foodName'] ?? '';
      favoritesMap[foodName] = true;
    }

    setState(() {
      _favoriteItems = favoritesMap;
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
                  (item['name'].toLowerCase().contains(searchQuery) ||
                      item['price'].toString().contains(searchQuery)) &&
                  (_selectedFoodType.isEmpty || item['type'] == _selectedFoodType))
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
              body: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFoodType = ''; // Show all foods
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'All',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFoodType = 'roti'; // Filter by 'Roti'
                              });
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
                          padding: const EdgeInsets.all(2),
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedFoodType = 'nasi'; // Filter by 'Roti'
                              });
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
                          padding: const EdgeInsets.all(2),
                          child: ElevatedButton(
                            onPressed: () {
                              _showFavoriteFood(_updatedUser.uid);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                'Show Favorites',
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        // Add more buttons for other food types
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
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
                                      color: const Color.fromARGB(255, 255, 255, 255)
                                          .withOpacity(0.5),
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
                                          width: 150,
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
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
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
                                                // Add the Favorite button here
                                               IconButton(
                                                  icon: Icon(
                                                    (_favoriteItems[filteredData[i]['name']] ?? false)
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    // Toggle the favorite state
                                                    setState(() {
                                                      final foodName = filteredData[i]['name'];
                                                      _favoriteItems[foodName] = !(_favoriteItems[foodName] ?? false);
                                                      _AddToFavorite(filteredData[i], _updatedUser.uid);
                                                    });
                                                  },
                                                ),
                                              ],
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
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
Future<void> _showFavoriteFood(String userId) async {
  CollectionReference favoritesCollection = FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('favorites');

  QuerySnapshot favoritesSnapshot = await favoritesCollection.get();

  List<String> favoriteFoodNames = [];
  favoritesSnapshot.docs.forEach((doc) {
    favoriteFoodNames.add(doc['foodName']);
  });

  // Query the 'foods' collection for favorited foods
  QuerySnapshot foodsSnapshot = await FirebaseFirestore.instance
      .collection('foods')
      .where('name', whereIn: favoriteFoodNames)
      .get();

  List<Map<String, dynamic>> favoriteFoods = [];
  foodsSnapshot.docs.forEach((foodDoc) {
    Map<String, dynamic> foodData = foodDoc.data() as Map<String, dynamic>;
    favoriteFoods.add(foodData);
  });

  // Show dialog for favorite foods
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Favorite Foods'),
        content: Container(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: favoriteFoods.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(favoriteFoods[index]['name']),
                    IconButton(
                      onPressed: () {
                        _AddToCart(favoriteFoods[index], userId);
                      },
                      icon: Icon(Icons.add_shopping_cart),
                    ),
                  ],
                ),
                // Add other details or customize ListTile as needed
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      );
    },
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

  Future<void> _AddToFavorite(Map<String, dynamic> foodData, String userId) async {
    String foodName = foodData['name'];
    CollectionReference favoriteCollection =
        FirebaseFirestore.instance.collection('users').doc(userId).collection('favorites');

    // Check if the food is already in favorites
    bool isFavorite = await favoriteCollection.doc(foodName).get().then((snapshot) => snapshot.exists);

    if (isFavorite) {
      // Food is already in favorites, remove it
      await favoriteCollection.doc(foodName).delete();
    } else {
      // Food is not in favorites, add it
      await favoriteCollection.doc(foodName).set({'foodName': foodName});
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

                      // Handle adding to 'favorite' collection
                      if (_favoriteItems[foodData['name']] == true) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('favorite')
                            .add({'foodName': foodData['name']});
                      } else {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(userId)
                            .collection('favorite')
                            .where('foodName', isEqualTo: foodData['name'])
                            .get()
                            .then((QuerySnapshot querySnapshot) {
                          querySnapshot.docs.forEach((doc) {
                            doc.reference.delete();
                          });
                        });
                      }

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
