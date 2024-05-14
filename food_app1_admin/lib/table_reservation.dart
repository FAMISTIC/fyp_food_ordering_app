import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TableReservationPage extends StatefulWidget {
  const TableReservationPage({Key? key}) : super(key: key);

  @override
  State<TableReservationPage> createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
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
              // Check if user's name is "admin", if yes, skip rendering
              if (user['name'] == "admin") {
                return const SizedBox(); // Return an empty SizedBox to skip rendering
              }

              final userReservations = user.reference.collection('table_reservation').snapshots();

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
                    stream: userReservations,
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      final reservations = snapshot.data!.docs;
                      return Column(
                        children: reservations.map((reservation) {
                          final date = reservation['Date'] != null
                              ? DateFormat('yyyy-MM-dd').format((reservation['Date'] as Timestamp).toDate())
                              : 'Not Available';
                          final time = reservation['Time'] != null ? reservation['Time'].toString() : 'Not Available';
                          final status = reservation['status'] ?? 'Not Available';

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
                                Text('Date: $date'),
                                Text('Time: $time'),
                                Text('Status: $status'),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        _updateStatus(reservation.reference, 'accepted');
                                      },
                                      child: const Text('Accept'),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        _updateStatus(reservation.reference, 'rejected');
                                      },
                                      child: const Text('Reject'),
                                    ),
                                  ],
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

  Future<void> _updateStatus(DocumentReference reservationRef, String newStatus) async {
    await reservationRef.update({'status': newStatus});
  }
}
