import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1_admin/constraints/textstyle.dart';
import 'package:food_app1_admin/user_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotifyPage extends StatefulWidget {
  const NotifyPage({Key? key}) : super(key: key);

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {


  late AppUser user;

  CollectionReference delUser =
      FirebaseFirestore.instance.collection('users');

  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
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
            title: const Center(child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: Padding(
                padding: EdgeInsets.only(right: 55.0),
                child: Text('Notify Users'),
              )),
            )),
            titleSpacing: 0.0,
            elevation: 0.0,
            backgroundColor: const Color.fromARGB(255, 129, 18, 18),
            shadowColor: Colors.grey,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(25),
                        bottomLeft: Radius.circular(25),
                      ),
                    ),
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
                                  child: Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                         try {
                                            await http.post(
                                              Uri.parse('https://fcm.googleapis.com/fcm/send'),
                                              headers: <String, String>{
                                                'Content-Type': 'application/json',
                                                'Authorization':
                                                    'key=AAAAfstLWrA:APA91bGlTPTuyr5GLBRnz7xH2ZqxrG0QEI_SXXnwgxGBFADCpEOujreIuBk7Lcv3wzlqlgf8vdUzMX__rhgsj3H5Mc_eUPi0l9VuMBycdfzihxTXIeErNKQZ0lbbQ2bBKZ5UYFcYKUPO',
                                              },
                                              body: jsonEncode(
                                                <String, dynamic>{
                                                  'priority': 'high',
                                                  'data': <String, dynamic>{
                                                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                                    'status': 'done',
                                                    'title': 'DJU CAFE',
                                                    'body': '${filteredData[i]['name']} \nCooking', // Concatenate additional text after the body
                                                  },
                                                  "notification": <String, dynamic>{
                                                    'title': 'DJU CAFE',
                                                    'body': '${filteredData[i]['name']} \nCooking', // Concatenate additional text after the body
                                                  },
                                                  'to': filteredData[i]['fcmToken'].toString(),
                                                },

                                              ),
                                            );
                                          } catch (e) {
                                            if (kDebugMode) {
                                              print("error push notification");
                                            }
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.kitchen,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                         try {
                                            await http.post(
                                              Uri.parse('https://fcm.googleapis.com/fcm/send'),
                                              headers: <String, String>{
                                                'Content-Type': 'application/json',
                                                'Authorization':
                                                    'key=AAAAfstLWrA:APA91bGlTPTuyr5GLBRnz7xH2ZqxrG0QEI_SXXnwgxGBFADCpEOujreIuBk7Lcv3wzlqlgf8vdUzMX__rhgsj3H5Mc_eUPi0l9VuMBycdfzihxTXIeErNKQZ0lbbQ2bBKZ5UYFcYKUPO',
                                              },
                                              body: jsonEncode(
                                                <String, dynamic>{
                                                  'priority': 'high',
                                                  'data': <String, dynamic>{
                                                    'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                                                    'status': 'done',
                                                    'title': 'DJU CAFE',
                                                    'body': '${filteredData[i]['name']} \nPreparing', // Concatenate additional text after the body
                                                  },
                                                  "notification": <String, dynamic>{
                                                    'title': 'DJU CAFE',
                                                    'body': '${filteredData[i]['name']} \nPreparing', // Concatenate additional text after the body
                                                  },
                                                  'to': filteredData[i]['fcmToken'].toString(),
                                                },

                                              ),
                                            );
                                          } catch (e) {
                                            if (kDebugMode) {
                                              print("error push notification");
                                            }
                                          }
                                        },
                                        icon: const Icon(
                                          Icons.restaurant,
                                          color: Colors.orange,
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
