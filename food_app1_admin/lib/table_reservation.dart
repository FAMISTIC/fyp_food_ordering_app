// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TableReservationPage extends StatefulWidget {
  const TableReservationPage({super.key});

  @override
  _TableReservationPageState createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchUsersWithReservations() async {
    List<Map<String, dynamic>> userList = [];
    QuerySnapshot usersSnapshot = await _firestore.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      var userData = userDoc.data() as Map<String, dynamic>;
      userData['id'] = userDoc.id;  // Store the user ID
      var reservationsSnapshot = await userDoc.reference.collection('table_reservation').get();

      userData['reservations'] = reservationsSnapshot.docs.map((doc) {
        var reservationData = doc.data() as Map<String, dynamic>;
        reservationData['id'] = doc.id;  // Store the reservation ID
        return reservationData;
      }).toList();
      userList.add(userData);
    }

    return userList;
  }

  Future<void> _updateReservationStatus(String userId, String reservationId, String newStatus) async {
    if (userId == null || reservationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User ID or Reservation ID is null')),
      );
      return;
    }
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('table_reservation')
          .doc(reservationId)
          .update({'status': newStatus});
      setState(() {}); // Refresh the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: Padding(
            padding: EdgeInsets.only(right: 55.0),
            child: Text('Table Reservation'),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUsersWithReservations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            List<Map<String, dynamic>> users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                var user = users[index];
                var userId = user['id']; // Assuming 'id' is the user document ID
                var reservations = user['reservations'] as List<Map<String, dynamic>>;

                if (user['name'] == "admin") {
                return const SizedBox(); // Return an empty SizedBox to skip rendering
              }

                return ExpansionTile(
                  title: Text(user['name'] ?? 'No Name'),
                  children: reservations.map((reservation) {
                    var reservationId = reservation['id'];
                    var tables = reservation['tables'] as List<dynamic>? ?? [];

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${reservation['Date']}'),
                          Text('Time: ${reservation['Time']} - Status: ${reservation['status']}'),
                          Text('Tables: ${tables.isNotEmpty ? tables.join(', ') : 'No tables'}'),
                          const SizedBox(height: 8.0),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _updateReservationStatus(userId, reservationId, 'accepted');
                                },
                                style: ElevatedButton.styleFrom(primary: Colors.green),
                                child: const Text('Accepted'),
                              ),
                              const SizedBox(width: 8.0),
                              ElevatedButton(
                                onPressed: () {
                                  _updateReservationStatus(userId, reservationId, 'declined');
                                },
                                style: ElevatedButton.styleFrom(primary: Colors.red),
                                child: const Text('Declined'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
