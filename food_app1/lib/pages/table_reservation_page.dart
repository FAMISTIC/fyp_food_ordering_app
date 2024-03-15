// ignore_for_file: library_private_types_in_public_api

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_app1/models/user_model.dart';
import 'package:food_app1/controllers/firebase_auth_service.dart';
import 'package:food_app1/pages/reservation_history_page.dart';

class TableReservationPage extends StatefulWidget {
  final AppUser user;

  const TableReservationPage({Key? key, required this.user}) : super(key: key);

  @override
  _TableReservationPageState createState() => _TableReservationPageState();
}

class _TableReservationPageState extends State<TableReservationPage> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Reservation'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReservationHistoryPage(user: widget.user)),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                initialValue: _selectedDate.toString(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                onTap: () => _selectTime(context),
                decoration: const InputDecoration(
                  labelText: 'Time',
                  suffixIcon: Icon(Icons.access_time),
                ),
                initialValue: _selectedTime.format(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitReservation,
                child: const Text('Make Reservation'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchUserDetails() async {
    AppUser? userDetails =
        await FirebaseAuthService().getUserDetails(widget.user.uid);

    if (userDetails != null) {
      setState(() {
      });
    } else {
      print("Error fetching user details.");
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

void _submitReservation() {
  if (_formKey.currentState!.validate()) {
    // Handle reservation logic here
    String userId = widget.user.uid;

    // Create a reference to the 'table_reservation' collection
    CollectionReference tableReservationCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('table_reservation');

    // Add a new document with a generated ID
    tableReservationCollection.add({
      'Date': _selectedDate,
      'Time': _selectedTime.format(context),
      'status': 'pending', // Set initial status
    }).then((value) {
      // Reservation successful
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation successful')),
      );
    }).catchError((error) {
      // Error handling
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to make reservation: $error')),
      );
    });
  }
}


}
