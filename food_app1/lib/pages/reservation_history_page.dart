import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';

class ReservationHistoryPage extends StatefulWidget {
  final AppUser user;

  const ReservationHistoryPage({Key? key, required this.user}) : super(key: key);

  @override
  _ReservationHistoryPageState createState() => _ReservationHistoryPageState();
}

class _ReservationHistoryPageState extends State<ReservationHistoryPage> {
  late AppUser _updatedUser;

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
        title: const Text('Reservation History'),
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
              return ListTile(
                title: Text('Date: ${data['Date']}'),
                subtitle: Text('Time: ${data['Time']}'),
                trailing: Text('Status: ${data['status']}'),
              );
            }).toList(),
          );
        },
      ),
    );
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
}
