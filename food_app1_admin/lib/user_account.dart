import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1_admin/add_account.dart';
import 'package:food_app1_admin/constraints/textstyle.dart';
import 'package:food_app1_admin/edit_account.dart';
import 'package:food_app1_admin/user_model.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {

  late AppUser user;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference delUser =
      FirebaseFirestore.instance.collection('users');

  Future<void> _delete(id) {
    return delUser
        .doc(id)
        .delete()
        .then((value) => print('User Deleted'))
        .catchError((_) => print('Something Error In Deleted User'));
  }

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }



  Future deleteUser(String id) async {
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

    const adminName = 'admin';
    
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            print('Something Wrong in HomePage');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final List<Map<String, dynamic>> firebaseData = [];
        snapshot.data?.docs.forEach((DocumentSnapshot documentSnapshot) {
          Map<String, dynamic> store =
              documentSnapshot.data() as Map<String, dynamic>;

          // Exclude admin user's data
          if (store['name'] != adminName) {
            firebaseData.add(store);
            store['id'] = documentSnapshot.id;
          }
        });

          // Filtered data based on search query
          final List filteredData = firebaseData
              .where((item) =>
                  item['name'].toLowerCase().contains(searchQuery) ||
                  item['phone'].toString().contains(searchQuery))
              .toList();

          return Scaffold(
            appBar: AppBar(
              title: Text('Crud Operation'.toUpperCase()),
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
                          builder: (context) => const AddPage(),
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
                          1: FixedColumnWidth(150),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: <TableRow>[
                          TableRow(
                            children: [
                              TableCell(
                                child: Container(
                                  color: Colors.greenAccent,
                                  child: Center(
                                    child: Text(
                                      'Name',
                                      style: txt,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  color: Colors.greenAccent,
                                  child: Center(
                                    child: Text(
                                      'Phone',
                                      style: txt,
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Container(
                                  color: Colors.greenAccent,
                                  child: Center(
                                    child: Text(
                                      'Action',
                                      style: txt,
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
                                  child: SizedBox(
                                    child: Center(
                                      child: Text(
                                        filteredData[i]['name'],
                                        style: txt2,
                                      ),
                                    ),
                                  ),
                                ),
                                TableCell(
                                  child: SizedBox(
                                    child: Center(
                                      child: Text(
                                        filteredData[i]['phone'].toString(),
                                        style: txt2,
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
                                              builder: (context) => EditPage(
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
