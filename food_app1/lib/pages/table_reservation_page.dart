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
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Center(child: Text('Table Reservation')),
        titleSpacing: 0.0,
        elevation: 0.0,
        backgroundColor: const Color.fromARGB(225,245, 93, 66),
        shadowColor: Colors.grey,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                  ),
                ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
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
                decoration:  InputDecoration(
                  labelText: 'Date',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // For rounded corners
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Default border color
                    width: 1, // Border width
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Border color when the field is not focused
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(224, 234, 47, 13), // Border color when the field is focused
                    width: 2, // Border width when focused
                  ),
                ),
                ),
                initialValue: _selectedDate.toString(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                readOnly: true,
                onTap: () => _selectTime(context),
                decoration:  InputDecoration(
                  labelText: 'Time',
                  suffixIcon: const Icon(Icons.access_time),
                  border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8), // For rounded corners
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Default border color
                    width: 1, // Border width
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(225, 245, 93, 66), // Border color when the field is not focused
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: Color.fromARGB(224, 234, 47, 13), // Border color when the field is focused
                    width: 2, // Border width when focused
                  ),
                ),
                ),
                initialValue: _selectedTime.format(context),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(225,245, 93, 66),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50.0),
                ),
              ),
                onPressed: _submitReservation,
                child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: const Center(
                  child:  Text('Make Booking',
                  style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ))),
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
