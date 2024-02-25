// ignore_for_file: avoid_unnecessary_containers, unnecessary_const

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1_admin/add_food.dart';
import 'package:food_app1_admin/edit_food.dart';
import 'package:food_app1_admin/food_model.dart';

class FoodPage extends StatefulWidget {
  const FoodPage({Key? key}) : super(key: key);

  @override
  State<FoodPage> createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  late Food food;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference delFood =
      FirebaseFirestore.instance.collection('foods');

  Future<void> _delete(id) {
    return delFood
        .doc(id)
        .delete()
        .then((value) => print('Food Deleted'))
        .catchError((_) => print('Something Error In Food User'));
  }

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  Future deleteFood(String id) async {
    await _delete(id);
  }

  String searchQuery = '';

  // Search functionality
  void search() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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

          // Clear the existing data
          List<Map<String, dynamic>> firebaseData = [];

          // Populate firebaseData with the data from Firestore
          snapshot.data?.docs.forEach((DocumentSnapshot documentSnapshot) {
            Map<String, dynamic> foodData =
                documentSnapshot.data() as Map<String, dynamic>;
            // Assuming 'id' is part of your Firestore document data
            String id = documentSnapshot.id;

            // Add the 'id' to the foodData map
            foodData['id'] = id;

            // Add the foodData map to firebaseData list
            firebaseData.add(foodData);
          });

          // Filtered data based on search query
          final List filteredData = firebaseData
              .where((item) =>
                  item['name'].toLowerCase().contains(searchQuery) ||
                  item['price'].toString().contains(searchQuery))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Food Availability'.toUpperCase()),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.amber),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddFood(),
                        ),
                      );
                    },
                    child: const Text('Add'),
                  ),
                )
              ],
            ),
            body: Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    onSubmitted: (value) => search(),
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  // Display Data
                  Expanded(
                    child: SingleChildScrollView(
                      child: Table(
                        border: TableBorder.all(),
                        columnWidths: const <int, TableColumnWidth>{
                          0: FixedColumnWidth(100),
                          1: FixedColumnWidth(100),
                          2: FixedColumnWidth(50),
                          3: FixedColumnWidth(100),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  color: Colors.greenAccent,
                                  child: const Center(
                                    child: Text(
                                      'Image',
                                      style: TextStyle(fontSize: 10),  
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  color: Colors.greenAccent,
                                  child: const Center(
                                    child: Text(
                                      'Food',
                                      style: TextStyle(fontSize: 10),                                
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  color: Colors.greenAccent,
                                  child: const Center(
                                    child: Text(
                                      'Price',
                                      style: TextStyle(fontSize: 10),                                
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  color: Colors.greenAccent,
                                  child: const Center(
                                    child: Text(
                                      'Action',
                                      style: TextStyle(fontSize: 10),                                
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          for (var i = 0; i < filteredData.length; i++) ...[
                            TableRow(
                              children: [
                                TableCell(
                                  child: Expanded(
                                    child: SizedBox(
                                      child: Center(
                                        child: Image.network(
                                          filteredData[i]['imagePath'],
                                          height:50,
                                          width: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: SizedBox(
                                    child: Center(
                                      child: Text(
                                        filteredData[i]['name'],
                                      style: const TextStyle(fontSize: 10),  
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: SizedBox(
                                    child: Center(
                                      child: Text(
                                        filteredData[i]['price'].toString(),
                                      style: const TextStyle(fontSize: 10),  
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditFood(
                                                docID: filteredData[i]['id'],
                                              ),
                                            ),
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      IconButton(
                                        //padding: const EdgeInsets.fromLTRB(0, 0, 100, 0),
                                        onPressed: () {
                                          _delete(filteredData[i]['id']);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
  
}
