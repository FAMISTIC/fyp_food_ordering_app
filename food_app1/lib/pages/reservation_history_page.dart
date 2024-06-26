import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:intl/intl.dart';

class ReservationHistoryPage extends StatefulWidget {
  final AppUser user;

  const ReservationHistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  _ReservationHistoryPageState createState() => _ReservationHistoryPageState();
}

class _ReservationHistoryPageState extends State<ReservationHistoryPage> {
  late AppUser _updatedUser;

  final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');
  final DateFormat timeFormatter = DateFormat('hh:mm a');

  @override
  void initState() {
    super.initState();
    _updatedUser = widget.user;
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(225, 245, 93, 66),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(25),
            bottomLeft: Radius.circular(25),
          ),
        ),
        title: const Center(
          child: Text('Table Reservation History'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              _showInfoPopup(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(_updatedUser.uid)
            .collection('table_reservation')
            .orderBy('Date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }
          final reservationDocuments = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['status'] != null;
          });
          if (reservationDocuments.isEmpty) {
            return const Center(
              child: Text('No reservations found'),
            );
          }
          return ListView(
            children: reservationDocuments.map((DocumentSnapshot document) {
              final data = document.data() as Map<String, dynamic>;
              final timestamp = data['Date'];
              final formattedTime = data['Time'];
              final tableNumber = data['tables'];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: ListTile(
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $timestamp'),
                      Text('Time: $formattedTime'),
                      Text('Table: $tableNumber'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Status: ${data['status']}'),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          _deleteReservation(document.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showInfoPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info'),
          content: const Text('This is the table reservation history of the user.'),
          actions: <Widget>[
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

  Future<void> _deleteReservation(String documentId) async {
    try {
      // Delete from the user's table_reservation subcollection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_updatedUser.uid)
          .collection('table_reservation')
          .doc(documentId)
          .delete();

      // Delete from the main table_reservation collection
      await FirebaseFirestore.instance
          .collection('table_reservation')
          .doc(documentId)
          .delete();

      // Optionally, refresh the UI after deletion
      _fetchUserDetails();
    } catch (e) {
      print("Error deleting reservation: $e");
      // Handle error if needed
    }
  }

  void _fetchUserDetails() async {
    AppUser? userDetails = await FirebaseAuthService().getUserDetails(widget.user.uid);

    if (mounted) {
      setState(() {
        _updatedUser = userDetails ?? _updatedUser; // Update only if userDetails is not null
      });
    } else {
      print("Widget is disposed, cannot call setState().");
    }
  }
}
